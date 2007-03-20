From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 20:21:19 +0100
Message-ID: <20070320192118.GD4286@bingen.suse.de>
References: <20070319.120854.30182994.davem@davemloft.net> <20070319.204712.118947830.davem@davemloft.net> <m13b40wnrb.fsf@ebiederm.dsl.xmission.com> <200703201428.50564.ak@suse.de> <m1ircvswzz.fsf@ebiederm.dsl.xmission.com> <20070320174159.GA4286@bingen.suse.de> <Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org> <20070320180359.GB4286@bingen.suse.de> <Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org, jbeulich@novell.com,
	jeremy@goop.org, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, virtualization@lists.osdl.org,
	anthony@codemonkey.ws, akpm@linux-foundation.org, mingo@elte.hu
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42293 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699AbXCTSWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 14:22:30 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2007 at 10:27:00AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 20 Mar 2007, Andi Kleen wrote:
> > 
> > The code never did that. In fact many of the problems we had initially
> > especially came out of that -- the fallback code that would handle
> > this case wasn't fully correct.
> 
> I don't keep my emails any more, but you *never* fixed the problems in 
> arch/*/kernel/traps.c.

I fixed that one after you dropped it (hmm, double checking: or at least
I thought I had fixed it, but don't see the code right now; will redo then) 
Basically it was just a one liner anyways - always check against all the
stacks that are there.


> Yes, the kernel/unwind.c issues generally got fixed. The infinite loops in 
> the *callers* never did.

There was later a weaker form that should have caught most loops, but admittedly
it wasn't 100% bullet-proof with exception stacks.

> 
> > Also frankly often your analysis about what went wrong was just
> > incorrect.
> 
> Still in denial, I see.
> 
> Do you still claim that "the fallback position always did the right 
> thing"

No initially it was buggy and that caused several of the crashes.

> Despite the fact that the unwinder had sometimes *corrupted* the 
> incoming information so much that the fallback position was the one that 
> oopsed? And no, you didn't fix that.

No, it oopsed because it was broken by itself.
Anyways that got fixed quickly.

> 
> And no, IT DID NOT use probe_kernel_address like you still claim.

There definitely was a patch that made it use it. You might have
not merged it though.
 
> Anyway, you work for Suse, I don't care what you do to the Suse kernel. 
> Maybe it will get stable some day. Somehow, I doubt it. 

So what is your proposed alternative to handle long backtraces? 
You didn't answer that question. Please do, I'm curious about your thoughts
in this area.

-Andi

