From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 15 Jan 2010 00:52:24 -0800 (PST)
Message-ID: <20100115.005224.257449393.davem@davemloft.net>
References: <20100115053352.31564.765.sendpatchset@krkumar2.in.ibm.com>
	<20100115.003636.199394610.davem@davemloft.net>
	<20100115095049.14190a50@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: simon.kagstrom@netinsight.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47247
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753243Ab0AOIwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 03:52:15 -0500
In-Reply-To: <20100115095049.14190a50@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Date: Fri, 15 Jan 2010 09:50:49 +0100

> On Fri, 15 Jan 2010 00:36:36 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
>> > Remove inline skb data in tcp_sendmsg(). For the few devices that
>> > don't support NETIF_F_SG, dev_queue_xmit will call skb_linearize,
>> > and pass the penalty to those slow devices (the following drivers
>> > do not support NETIF_F_SG: 8139cp.c, amd8111e.c, dl2k.c, dm9000.c,
>> > dnet.c, ethoc.c, ibmveth.c, ioc3-eth.c, macb.c, ps3_gelic_net.c,
>> > r8169.c, rionet.c, spider_net.c, tsi108_eth.c, veth.c,
>> > via-velocity.c, atlx/atl2.c, bonding/bond_main.c, can/dev.c,
>> > cris/eth_v10.c).
>> 
>> I was really surprised to see r8169.c in that list.
>> 
>> It even has all the code in it's ->ndo_start_xmit() method
>> to build fragments properly and handle segmented SKBs, it
>> simply doesn't set NETIF_F_SG in dev->features for whatever
>> reason.
> 
> The same thing goes for via-velocity.c, it's turned on via ethtool
> though (ethtool_op_set_sg).

Indeed, see my reply to Krishna's ethtool_op_set_sg() patch.

I think it's a cruddy way to do things, SG ought to be on by
default always unless it is defective.  And if it's defective
support should be removed entirely.
