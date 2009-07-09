From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 09:56:50 +0200
Message-ID: <1247126210.9777.317.camel@twins>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
	 <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andrew Morton <akpm@linux-foundation.org>, oleg@redhat.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758889AbZGIH5M@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-07-08 at 17:01 -0700, Linus Torvalds wrote:
> Looking at the people looking at SYSTEM_RUNNING, I do note some odd cases. 
> Why the heck does kernel/perf_counter.c do it, for example?

Ah, those are the swcounter and other probe entry points. I've had
several cases where we called into the perf counter code from those
points before it was initialized, getting in kernel segfaults due to
dereferencing uninitialized data etc..

I could keep a variable that tracked the perf_counter_init() state, and
use that instead if you prefer?
