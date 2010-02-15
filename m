From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v4 4/7] tcp: input header length, prediction, and timestamp bugs
Date: Mon, 15 Feb 2010 20:15:48 +0100
Message-ID: <20100215191548.GH21783@one.firstfloor.org>
References: <4B793CAA.2030902@gmail.com> <4B793E8F.30208@gmail.com> <20100215151055.GG21783@one.firstfloor.org> <4B799A86.8040303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B799A86.8040303@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2010 at 02:03:34PM -0500, William Allen Simpson wrote:
> Andi Kleen wrote:
> >On Mon, Feb 15, 2010 at 07:31:11AM -0500, William Allen Simpson wrote:
> >>Don't use output calculated tp->tcp_header_len for input decisions.
> >>While the output header is usually the same as the input (same options
> >>in both directions), that's a poor assumption. In particular, Sack will
> >>be different. Newer options are not guaranteed.
> >
> >Is this a bug fix? 
> >
> Yes.  One of many, all inter-related.
> 
> I don't know how much description folks want in the patch "summary", so

A good way  to find out is to read some of the existing (newer) changelogs.

> simply used declarative statements that are one-to-one with the order of
> the patch, but it took me a bit to grok this problem!

It's useful to distingush bug fixes from cleanups from optimizations etc.

> 
> 1) unknown options can be stripped out of the header in middleware, see
> RFC 1122 section 4.2.2.5.
> 
> 2) new options Cookie Pair and 64-bit Timestamps (defined in patch 7).
> 
> 3) stripping them leaves a Sack covering 1 segment, which has the exact
> same word count as 32-bit Timestamps.  Boom!  All the silly checks

Boom == the code would use sack data as time stamp?

> against the size of the options field (instead of the proper saw_tstamp)
> start setting fields based on completely useless data!
> 
> 4) and of course, using the size of the previous output to predict the
> expected input header size is a poor assumption (to be generous).

Invalid fast path heuristics are probably not bugs in the strict sense,
as long as they do not lead to actually incorrect behaviour.

> 
> There are 29+ options these days, not 4 or 5.  There are options that
> are only sent one way.  There are options that have different data in
> different directions.
> 
> Yes, it was originally for TCPCT, but fixes a broad spectrum of bugs.

It would be good if you could extract the pure bug fixes from the rest.

Normally there's a "fast path" in patch submission for bug fixes
(e.g. might still go in for the current kernel). The other stuff
goes in slower.

> 
> 
> >>Stand-alone patch, originally developed for TCPCT.
> >
> >Normally it would be better to split this into smaller patches
> >that do one thing at a time (typically this requires getting
> >used to patch stack tools like "quilt")
> >
> >But it's not too bad here.
> >
> There are small efficiency patches included, but it would be likely
> impossible to split them from the bug fixes without re-writing the same
> code over and over again.  And I'm doing these patch splits by hand....

That's the problem. Get the right tools. Splitting patches by hand
is usually the wrong approach for anything non trivial.

> I did recently learn how to maintain branches that are branches on top of
> each other, so I've got tcpct1, tcpct2, and tcpct3 for the 3 parts.  But
> it's a pain to keep updated with git fetch, and checkout, and rebase,
> for each branch.

I personally use quilt for such patchkits, it's much easier.

For git I believe there are several extensions that implement quilt
like patch stacking.

But there are different ways to skin a cat and people do it differently.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
