From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 00:29:20 +0100
Message-ID: <20100105232920.GA8002@del.dom.local>
References: <20100105230746.GA6612@del.dom.local>
 <4B43C86A.1090004@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:48119 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812Ab0AEX30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 18:29:26 -0500
Content-Disposition: inline
In-Reply-To: <4B43C86A.1090004@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 06:16:58PM -0500, Michael Breuer wrote:
> On 1/5/2010 6:07 PM, Jarek Poplawski wrote:
> >David Miller wrote, On 12/27/2009 05:11 AM:
> >
> >>From: David Miller<davem@davemloft.net>
> >>Date: Sat, 26 Dec 2009 19:44:18 -0800 (PST)
> >>
> >>>From: Stephen Hemminger<shemminger@linux-foundation.org>
> >>>Date: Sat, 26 Dec 2009 14:05:44 -0800
> >>>
> >>>>Other drivers may have same problem, I really think this ought
> >>>>to be done at higher level.
> >>>I tend to agree with you, and I thought we had handled all
> >>>cases.  Let's simply make AF_PACKET linearize the link
> >>>level header before sending things out to the transmit path.
> >>>
> >>>I can work on this if you want.
> >>Actually Stephen, I took a look and I can't see how AF_PACKET
> >>can create this situation.
> >>
> >>It always copies into the linear area of the SKB it allocates
> >>for sendmsg() processing.  Whether the data comes from sendmsg
> >>data or the mmap() ring buffer.
> >Actually, I think there is a bug in this place, but of course this
> >might be unconnected. Anyway, Michael, could you try this patch?
> >BTW, did you try with CONFIG_PACKET_MMAP disabled?
> I did not try with CONFIG_PACKET_MMAP disabled.
> 
> Please let me know which permutations of the following would be most
> valuable to test:
> Davids patch in/out
> The attached patch in/out
> CONFIG_PACKET_MMAP on/off
> 
> I'm thinking your patch in, david's out, with and without
> CONFIG_PACKET_MMAP.

I'm not sure about David's (except do it first ;-), but try my patch
with CONFIG_PACKET_MMAP on; if there is no change, CONFIG_PACKET_MMAP
off, without any patches.

Thanks,
Jarek P.
