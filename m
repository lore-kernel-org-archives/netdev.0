From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 21:23:52 +0100
Message-ID: <20070320202352.GF4286@bingen.suse.de>
References: <20070319.204712.118947830.davem@davemloft.net> <m13b40wnrb.fsf@ebiederm.dsl.xmission.com> <200703201428.50564.ak@suse.de> <m1ircvswzz.fsf@ebiederm.dsl.xmission.com> <20070320174159.GA4286@bingen.suse.de> <Pine.LNX.4.64.0703200947501.6730@woody.linux-foundation.org> <20070320180359.GB4286@bingen.suse.de> <Pine.LNX.4.64.0703201022040.6730@woody.linux-foundation.org> <20070320192118.GD4286@bingen.suse.de> <Pine.LNX.4.64.0703201145570.6730@woody.linux-foundation.org>
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
Received: from ns2.suse.de ([195.135.220.15]:45898 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934043AbXCTTZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 15:25:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703201145570.6730@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2007 at 11:49:39AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 20 Mar 2007, Andi Kleen wrote:
> > 
> > So what is your proposed alternative to handle long backtraces? 
> > You didn't answer that question. Please do, I'm curious about your thoughts
> > in this area.
> 
> the thing is, I'd rather see a long backtrace that is hard to decipher but 
> that *never* *ever* causes any additional problems, over a pretty one.

Well it causes additional problems. We had some cases where it was really
hard to distingush garbage and the true call chain. I can probably dig
out some examples if you want.

With lots of call backs (e.g. common with sysfs) it is also frequently
not obvious how the call chains are supposed to go.

I would have agreed with you in the 2.4 time frame. It was also
always fun to explain this to a newbie with oopses and watch their
face when they secretly think you're crazy ;-) But code is getting
much and more complex unfortunately and I had a few cases where
it was really ugly to sort them out. 

> Because that's really the issue: do you want a "pretty" backtrace, or do 
> you want one that is rock solid but has some crud in it.

I just want an as exact backtrace as possible. I also think
that we can make the unwinder robust enough.

> I'll take the rock solid one any day. Especially as even the pretty one 
> won't fix the most common problem, which is "I don't see the caller" (due 
> to inlining or tail-calls).

The problem is not one or a few levels of calls. That can be always figured
out from the source. The problem is when you have a double
digit number of them with non obvious (dynamic indirect) dependencies.  Yes it 
can be figured out too, but it is a long and very annoying process
with lots of grepping etc. and even then you sometimes can't be 100% 
sure in some cases. 

It's also a mechanic process that just cries to be done by a machine instead.

> In contrast, the ugly backtrace will have some "garbage entries" from 
> previous frames that didn't get overwritten, but there have actually been 

If it was only a few that would be great ...

-Andi

