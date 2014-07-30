From: Greg KH <greg@kroah.com>
Subject: Re: Fwd: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Tue, 29 Jul 2014 17:22:55 -0700
Message-ID: <20140730002255.GA16109@kroah.com>
References: <1836813.giEndUKvmp@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46779 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753397AbaG3AX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 20:23:26 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id EEED12413C
	for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 20:23:23 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <1836813.giEndUKvmp@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2014 at 05:12:55PM +0200, Thomas Jarosch wrote:
> Hi Greg,
> 
> I don't have the original patch email, but please include
> the mentioned commit
> 
> ------------------------------------------
> commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
> Author: Eric Dumazet <edumazet@google.com>
> ipv4: set transport header earlier
> ------------------------------------------
> 
> in the 3.4.x stable tree.
> 
> After updating from 3.4.91 to 3.4.96, TCP connections
> from Windows 7 clients slowed down to a crawl.
> (to be precise: totally unusable)
> 
> The commit recommended by Florian Westphal fixes it immediately.
> 
> Best regards,
> Thomas
> 
> ----------  Forwarded Message  ----------
> 
> Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
> Date: Friday, 27. June 2014, 11:05:25
> From: Florian Westphal <fw@strlen.de>
> To: jungwon park <jwpark2@whitecode.co.kr>
> CC: netdev@vger.kernel.org
> 
> jungwon park <jwpark2@whitecode.co.kr> wrote:
> > When using the linux router is turned on GRO, router send the 
> 'fragmentation
> > needed' packets to the sender.
> 
> Indeed 8-(
> 
> > When I turned off GRO, the router operate normally, and there is no 
> problem.
> > and with 3.4.91 kernel, the router has no problem.
> > 
> > I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
> > (http://patchwork.ozlabs.org/patch/345509/)
> > When I revert this patch, the router has no problem.
> 
> Can you please cherry-pick following patch on top of vanilla 3.4.92?
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
> 
> commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
> Author: Eric Dumazet <edumazet@google.com>
> ipv4: set transport header earlier
> 
> I think that should fix this bug, it should apply cleanly on top of
> 3.4.y tree.
> 
> [ patch is in 3.11, also backported to 3.10.y tree ]
> 
> The problem is that, when dealing with GRO packets, we try to determine
> the size of the individual packets.  To do this, we rely on the
> transport header.
> 
> Unfortunately the transport header is not set for the forward path in 3.4,
> so we look at the network header instead.

Why would this patch matter, as commit 45f00f99d6e, which this patch
fixes, is not in the 3.4-stable tree at all.

Also, network stable patches need to go through the network maintainer,
not me directly.

thanks,

greg k-h
