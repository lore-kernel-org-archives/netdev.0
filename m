From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next] net: increase the size of priv_flags and add IFF_OVS_DATAPATH
Date: Mon, 23 Aug 2010 23:48:05 -0700
Message-ID: <6280.1282632485@death>
References: <20100824022637.GA11820@verge.net.au> <20100823.204408.35817944.davem@davemloft.net>
Cc: horms@verge.net.au, netdev@vger.kernel.org, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:54918 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab0HXGsN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 02:48:13 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7O6T9lB023117
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 02:29:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7O6m8mc336172
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 02:48:08 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7O6m8js014937
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 03:48:08 -0300
In-reply-to: <20100823.204408.35817944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Simon Horman <horms@verge.net.au>
>Date: Tue, 24 Aug 2010 11:26:41 +0900
>
>> IFF_OVS_DATAPATH is a place-holder for the Open vSwitch datapath
>> which I am preparing to submit for merging.
>> 
>> As all 16 bits of priv_flags are already assigned flags, also increase
>> the size of priv_flags to 32 bits.
>> 
>> Unfortunately, by my calculations this increases the size of
>> struct net_device by 4 bytes on 32bit architectures and
>> 8 bytes on 64 bit architectures. I couldn't see an obvious
>> way to avoid that.
>> 
>> Cc: Jesse Gross <jesse@nicira.com>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>
>I can't think of a better way out of this, so applied for now.
>
>Maybe somehow some of those bonding specific flags can get put
>down into the bonding private structure.  However, that might
>not be possible if the sole reason those live in ->priv_flags
>is to allow tests of the flags outside of the bonding code.

	That is indeed the case: it's to permit the flags to be tested
primarily in the netif_receive_skb path (inside __skb_bond_should_drop)
without calling into bonding via a hook or the like.  There's also one
check in fcoe to not support fcoe over a subset of bonding modes, from
the looks of it.

	I don't think the bonding tests could be rolled up into a
dev->rx_handler, either, because the bonding stuff has to happen before
any delivery attempts (it may affect skb->dev or packet delivery).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
