From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops callsites to make them patchable
Date: Tue, 20 Mar 2007 18:42:00 +0100
Message-ID: <20070320174159.GA4286@bingen.suse.de>
References: <20070319.120854.30182994.davem@davemloft.net> <20070319.204712.118947830.davem@davemloft.net> <m13b40wnrb.fsf@ebiederm.dsl.xmission.com> <200703201428.50564.ak@suse.de> <m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org,
	virtualization@lists.linux-foundation.org, jbeulich@novell.com,
	jeremy@goop.org, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chrisw@sous-sol.org, virtualization@lists.osdl.org,
	anthony@codemonkey.ws, akpm@linux-foundation.org, mingo@elte.hu
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40433 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbXCTQnC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 12:43:02 -0400
Content-Disposition: inline
In-Reply-To: <m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2007 at 10:25:20AM -0600, Eric W. Biederman wrote:
> What I recall observing is call traces that made no sense.  Not just
> extra noise in the stack trace but things like seeing a function that
> has exactly one path to it, and not seeing all of the functions on
> that path in the call trace.

That's tail call/sibling call optimization. No unwinder can untangle that
because the return address is lost.  But it's also an quite important optimization.

> >
> > In 2.4 it was often very reasonable to just sort out the false positives,
> > but with sometimes 20-30+ level deep call chains in 2.6 with many callbacks that
> > just
> > gets far too tenuous. 
> 
> Hmm.  I haven't seen those traces, but I wonder if the size of those
> stack traces indicates potential stack overflow problems.

Most functions have quite small frames, so 20-30 is still not a problem

> Do you also validate the unwind data?

There are many sanity checks in the unwind code and it will fall back
to the old unwinder when it gets stuck.

> 
> > Although in future it would be good if people did some more analysis in root
> > causes for failures before let the paranoia take over and revert patches.
> >
> > We see a good example here of what I call the JFS/ACPI effect: code gets merged
> > too early with some visible problems. It gets a bad name and afterwards people
> > never look objectively at it again and just trust their prejudices. 
> 
> I don't know.  The impression I got was the root cause analysis stopped 
> when it was observed that the code was unsuitable for solving the problem.

No, me and Jan fixed all reported bugs as far as I know.

-Andi

