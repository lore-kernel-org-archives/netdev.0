From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH] tags: Fix DEFINE_PER_CPU expansions
Date: Tue, 1 Mar 2016 19:18:42 +0100
Message-ID: <20160301181842.GX6357@twins.programming.kicks-ass.net>
References: <20160301102625.GQ6357@twins.programming.kicks-ass.net>
 <20160301163707.GF3965@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, rjw@rjwysocki.net,
	konrad.wilk@oracle.com, Ingo Molnar <mingo@kernel.org>,
	paulmck@linux.vnet.ibm.com, davem@davemloft.net,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40308 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbcCASSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:18:48 -0500
Content-Disposition: inline
In-Reply-To: <20160301163707.GF3965@htj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 11:37:07AM -0500, Tejun Heo wrote:
> Hello, Peter.
> 
> On Tue, Mar 01, 2016 at 11:26:25AM +0100, Peter Zijlstra wrote:
> > 
> > $ make tags
> >   GEN     tags
> > ctags: Warning: drivers/acpi/processor_idle.c:64: null expansion of name pattern "\1"
> > ctags: Warning: drivers/xen/events/events_2l.c:41: null expansion of name pattern "\1"
> > ctags: Warning: kernel/locking/lockdep.c:151: null expansion of name pattern "\1"
> > ctags: Warning: kernel/rcu/rcutorture.c:133: null expansion of name pattern "\1"
> > ctags: Warning: kernel/rcu/rcutorture.c:135: null expansion of name pattern "\1"
> > ctags: Warning: kernel/workqueue.c:323: null expansion of name pattern "\1"
> > ctags: Warning: net/ipv4/syncookies.c:53: null expansion of name pattern "\1"
> > ctags: Warning: net/ipv6/syncookies.c:44: null expansion of name pattern "\1"
> > ctags: Warning: net/rds/page.c:45: null expansion of name pattern "\1"
> > 
> > Which are all the result of the DEFINE_PER_CPU pattern:
> > 
> > scripts/tags.sh:200:	'/\<DEFINE_PER_CPU([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> > scripts/tags.sh:201:	'/\<DEFINE_PER_CPU_SHARED_ALIGNED([^,]*, *\([[:alnum:]_]*\)/\1/v/'
> > 
> > The below cures them. All except the workqueue one are within reasonable
> > distance of the 80 char limit. TJ do you have any preference on how to
> > fix the wq one, or shall we just not care its too long?
> 
> Urgh... I really hate the fact that we're putting on arbitrary
> formatting constraints to compensate for shortcomings in an
> out-of-line utility.

Yes it does.

I'm not too bothered if you don't want to fix this, I just figured I'd
have a stab at fixing all this, since I regularly run 'make tags' and
got tired of seeing the warns.

> Can't it do multiline regex?

Apparently not:

  https://sourceforge.net/p/ctags/feature-requests/38/
