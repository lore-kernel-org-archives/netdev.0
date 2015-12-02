From: David Miller <davem@davemloft.net>
Subject: Re: Increasing skb->mark size
Date: Wed, 02 Dec 2015 12:29:19 -0500 (EST)
Message-ID: <20151202.122919.637365365005967628.davem@davemloft.net>
References: <565E1A9F.7040906@iogearbox.net>
	<20151202025835.GL15533@two.firstfloor.org>
	<565E84D5.5070009@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, daniel@iogearbox.net, lorenzo@google.com,
	Matt.Bennett@alliedtelesis.co.nz, netdev@vger.kernel.org,
	Luuk.Paulussen@alliedtelesis.co.nz
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964880AbbLBR3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 12:29:23 -0500
In-Reply-To: <565E84D5.5070009@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 1 Dec 2015 21:42:45 -0800

> On 12/1/15 6:58 PM, Andi Kleen wrote:
>>>> - skb_iff is either skb->dev->iff or 0. so it could be replaced with a
>>>> single bit flag for the 0 case.
>>>
>>> ... and that one wouldn't work on ingress.
>>
>> Please explain.
> 
> skb->dev is dropped fairly early in the Rx path. skb_iif is needed for
> example for IP_CMSG_PKTINFO.

Right, we cannot let skb->dev escape the software interrupt handler, yet
we need some cheap reference to it for socket options et al.

Andi, this is not a 15-20 minute problem to solve.  Many very smart people
have spent days/weeks/months trying to even discover reasonable ways in
which to shrink sk_buff.

The low hanging fruit has been gone for a very long time now.
