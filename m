From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Fri, 22 Aug 2008 10:46:26 -0700
Message-ID: <20080822174626.GC2551@susedev.qlogic.org>
References: <20080821185402.GD31526@susedev.qlogic.org> <48AE8549.6090705@garzik.org> <20080822.024252.193704871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Linux-Driver@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13655 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbYHVRq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 13:46:59 -0400
Content-Disposition: inline
In-Reply-To: <20080822.024252.193704871.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 02:42:52AM -0700, David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Fri, 22 Aug 2008 05:22:17 -0400
> 
> > - The kmap use is interesting
> 
> It's so much easier to just always tack on the pages or whatever
> and use __pskb_pull_tail(skb, SOME_MIN_HEADER_LENGTH)

I will look into changing per your suggestion.  This messy section
runs when jumbo frames arrive that aren't TCP/UDP.  I didn't know
about the API you point out.  Thanks very much.

> 
> I also notice that this driver does not do:
> 
> 	skb_reserve(skb, NET_IP_ALIGN);
> 
> on RX packets to get the IP headers properly 4-byte aligned aligned
> after the ethernet header.

The chip currenly has problems with 2-byte aligned receive buffers.
It will be fixed in the next turn.

