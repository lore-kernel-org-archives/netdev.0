From: Andrew McDonald <andrew@mcdonald.org.uk>
Subject: Re: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Tue, 16 Oct 2007 21:15:50 +0100
Message-ID: <20071016201550.GC28453@mcdonald.org.uk>
References: <20071014111147.GE20850@mcdonald.org.uk> <Pine.LNX.4.64.0710150849580.17284@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from widget.mcdonald.org.uk ([81.187.72.227]:2448 "EHLO
	widget.mcdonald.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965475AbXJPUPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 16:15:53 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710150849580.17284@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 08:51:16AM +0300, Pekka Savola wrote:
> Took off linux-man from cc:,
> 
> On Sun, 14 Oct 2007, Andrew McDonald wrote:
> >+The tapped packets are not forwarded by the kernel, it is the
> >+user's responsibility to send them out again.
> 
> This is probably incompliant (and from users' perspective, 
> unacceptible) behaviour that IMHO should be fixed.

I disagree. This is basically the behaviour you want.

It might be an improvement to that sentence to simply say: "The tapped
packets are not forwarded by the kernel." The second half of the
sentence possibly suggests that you always want to forward the packet
after router alert processing.

For why you don't want to packets to be forwarded, consider a simple
example that applies to something like RSVP:
- packet hits router, identified as potentially interesting from router
alert option
- packet passed to user space, confirmed as really interesting and
processed
- create new packet (based on the one that came in and the RSVP
processing you've done) and send it out

You don't want the original packet you received to be forwarded, only
your new packet.

There is the possible case that you decide that you aren't interested
in the packet once it has reached userspace, in which case the user
will need to forward it themself. I can imagine ways of improving this
(e.g. LSF/BPF filters that run before deciding not to forward the
packet to reduce the likelihood of intercepting 'uninteresting'
packets), but they would not completely remove this situation.

-- 
Andrew McDonald
E-mail: andrew@mcdonald.org.uk
http://www.mcdonald.org.uk/andrew/
