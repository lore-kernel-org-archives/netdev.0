From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 09:43:00 -0500
Message-ID: <1247150580.21295.937.camel@calx>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
	 <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
	 <1247145977.21295.899.camel@calx>  <1247147206.7439.2.camel@twins>
	 <1247149093.21295.915.camel@calx>  <1247149862.12784.6.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andrew Morton <akpm@linux-foundation.org>, oleg@redhat.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:47700 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760730AbZGIOqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 10:46:08 -0400
In-Reply-To: <1247149862.12784.6.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-09 at 16:31 +0200, Peter Zijlstra wrote:
> On Thu, 2009-07-09 at 09:18 -0500, Matt Mackall wrote:
> > 
> > Sorry if I was unclear. I'm suggesting setting the count so the existing
> > PREEMPT_ACTIVE test here fires:
> > 
> > int __sched _cond_resched(void)
> > {
> >         if (need_resched() && !(preempt_count() & PREEMPT_ACTIVE) &&
> >                                         system_state == SYSTEM_RUNNING) {
> >                 __cond_resched();
> >                 return 1;
> >         }
> >         return 0;
> > }
> 
> Right, /me read preempt and thought a simple preempt inc but didn't read
> the code. Shame on me.
> 
> So something like (utterly untested and such)

Yeah, that's what I had in mind. Probably throw in a define:

/* for disabling scheduling in early boot */
#define PREEMPT_EARLY (1 + PREEMPT_ACTIVE)

and slap a comment on the sub_preempt_count().

Does anything actually use scheduler_running yet? Perhaps my tree is
old.

Also, might_sleep's use of system_state probably bears revisiting.

-- 
http://selenic.com : development and support for Mercurial and Linux


