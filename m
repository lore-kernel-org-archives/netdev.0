From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 07:56:42 -0500
Message-ID: <1247144202.21295.869.camel@calx>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
	 <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
	 <1247126210.9777.317.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andrew Morton <akpm@linux-foundation.org>, oleg@redhat.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:46409 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759040AbZGIM6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 08:58:03 -0400
In-Reply-To: <1247126210.9777.317.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-09 at 09:56 +0200, Peter Zijlstra wrote:
> On Wed, 2009-07-08 at 17:01 -0700, Linus Torvalds wrote:
> > Looking at the people looking at SYSTEM_RUNNING, I do note some odd cases. 
> > Why the heck does kernel/perf_counter.c do it, for example?
> 
> Ah, those are the swcounter and other probe entry points. I've had
> several cases where we called into the perf counter code from those
> points before it was initialized, getting in kernel segfaults due to
> dereferencing uninitialized data etc..
> 
> I could keep a variable that tracked the perf_counter_init() state, and
> use that instead if you prefer?

Looks like that'd be more accurate. Linus's proposed patch might break
your current assumptions.

-- 
http://selenic.com : development and support for Mercurial and Linux


