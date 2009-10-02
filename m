From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: SPLICE_F_NONBLOCK semantics...
Date: Fri, 2 Oct 2009 09:47:54 +0200
Message-ID: <20091002074754.GE14918@kernel.dk>
References: <20091001.151102.09812927.davem@davemloft.net> <alpine.LFD.2.01.0910011516390.6996@localhost.localdomain> <20091001.152717.187318570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, eric.dumazet@gmail.com,
	jgunthorpe@obsidianresearch.com, vl@samba.org,
	opurdila@ixiacom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([93.163.65.50]:39824 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288AbZJBHrv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 03:47:51 -0400
Content-Disposition: inline
In-Reply-To: <20091001.152717.187318570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 01 2009, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 1 Oct 2009 15:21:44 -0700 (PDT)
> 
> > On Thu, 1 Oct 2009, David Miller wrote:
> >> 
> >> It depends upon our interpretation of how you intended the
> >> SPLICE_F_NONBLOCK flag to work when you added it way back
> >> when.
> >> 
> >> Linus introduced  SPLICE_F_NONBLOCK in commit 29e350944fdc2dfca102500790d8ad6d6ff4f69d
> >> (splice: add SPLICE_F_NONBLOCK flag )
> >> 
> >>   It doesn't make the splice itself necessarily nonblocking (because the
> >>   actual file descriptors that are spliced from/to may block unless they
> >>   have the O_NONBLOCK flag set), but it makes the splice pipe operations
> >>   nonblocking.
> >> 
> >> Linus intention was clear : let SPLICE_F_NONBLOCK control the splice pipe mode only
> > 
> > Ack. The original intent was for the flag to affect the buffering, not the 
> > end points.
> 
> Great, thanks for reviewing.
> 
> > Although the more I think about it, the more I suspect that the
> > whole NONBLOCK thing should probably have been two bits, and simply
> > been about "nonblocking input" vs "nonblocking output" (so that you
> > could control both sides on a call-by-call basis).
> 
> I think we could still extend things in this way if we wanted to.
> So if you specify the explicit input and/or output nonblock flag,
> it takes precedence over the SPLICE_F_NONBLOCK thing.

Yes I agree, thank god for having a 'flags' parameter for the syscalls
:-). I'll make a note to add and test bidirectional nonblock hints.

The net patch looks fine and correct to me, feel free to add my acked-by
if you want.

-- 
Jens Axboe

