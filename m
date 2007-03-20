From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 19:03:59 +0100
Message-ID: <20070320180359.GB4286@bingen.suse.de>
References: <20070319.120854.30182994.davem@davemloft.net> <20070319.204712.118947830.davem@davemloft.net> <m13b40wnrb.fsf@ebiederm.dsl.xmission.com> <200703201428.50564.ak@suse.de> <m1ircvswzz.fsf@ebiederm.dsl.xmission.com> <20070320174159.GA4286@bingen.suse.de> <Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
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
Received: from ns1.suse.de ([195.135.220.2]:41965 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965496AbXCTRE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 13:04:59 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2007 at 09:52:42AM -0700, Linus Torvalds wrote:
> The ones I reported were all about trusting the stack contents implicitly, 

The latest version added the full double check you wanted - every
new RSP is validated against the current stack or the exception stacks.

> and assuming that the unwind info was there and valid. Using things like 

The code never did that. In fact many of the problems we had initially
especially came out of that -- the fallback code that would handle
this case wasn't fully correct.

> "__get_user()" didn't fix it, because if a WARN_ON() happened while we 
> held the mm semaphore and the unwind info was bogus, it would take a 
> page-fault and deadlock.

That was fixed too even before you dropped it by using probe_kernel_address()

> And I told you guys this. Over *months*. And you ignored me. You told me 
> everything was fine. Each time, somebody else ended up reporting a hang 
> where the unwinder was at fault. 

That was because most of the bugs were reported many times duplicated --
and reports from older releases kept streaming in even after the fix
went in.

Also frankly often your analysis about what went wrong was just
incorrect.
 
> And you clearly *still* haven't accepted the fact that the code was buggy. 

There were some bugs, but they were all fixed. Or at least I hope -- 
we will find out during testing.

> Does anybody wonder why I wouldn't merge it back?

So do you have an alternative to the unwinder? Don't tell me 
"real men decode 30+ entry long stack traces with lots of callbacks
by hand". Or do you prefer to use frame pointers everywhere? 

-Andi

