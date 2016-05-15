From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab
 name
Date: Sun, 15 May 2016 07:22:40 +0200
Message-ID: <20160515052240.GA10828@1wt.eu>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
 <CA+55aFx_PuzNC0riLEN7PUpVnvQg374ZqCYBV-Uw6Be-OA=DwQ@mail.gmail.com>
 <20160514213322.GD9763@1wt.eu>
 <CA+55aFwthSgQyG_=mTpwctpOWqc1D7KgWHrdrqh+PLiFjuT=_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:29726 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbcEOFWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 01:22:49 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFwthSgQyG_=mTpwctpOWqc1D7KgWHrdrqh+PLiFjuT=_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2016 at 03:21:31PM -0700, Linus Torvalds wrote:
> On Sat, May 14, 2016 at 2:33 PM, Willy Tarreau <w@1wt.eu> wrote:
> >
> > Why simply not cast the atomic to (unsigned long long) instead of (u64)
> > so that %llu always matches ?
> 
> Yes, that fixes the problem. It's just more typing, and annoying. The
> fact that MS got it right while posix and gcc screwed it up is a bit
> embarrassing..

Well on the other hand, because of this MS still has problems porting
code from 32 to 64 bit. The real problem is that on both sides they
imagined that you needed only one way to specify your types. In practice
users generally want either the most optimal types for the architecture
because they don't care about the size (char, int, size_t, void *...)
or a specific size. This last one is annoying to use with printf format.

> If we ever start using __uint128_t, we'll have even more problems in
> this area. Oh well.

Definitely.

Willy
