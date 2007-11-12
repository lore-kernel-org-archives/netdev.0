From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.24-rc1-gb4f5550 oops
Date: Mon, 12 Nov 2007 19:05:49 +0100
Message-ID: <1194890749.9713.17.camel@twins>
References: <20071105061158.3174d24d@worthy.swandive.local>
	 <200711082242.21869.rjw@sisk.pl>
	 <20071108221951.71224bd8@worthy.swandive.local>
	 <200711082349.19344.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Grant Wilson <grant.wilson@zen.co.uk>, Ingo Molnar <mingo@elte.hu>,
	lkml <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, vatsa <vatsa@linux.vnet.ibm.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:50164 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbXKLSGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 13:06:09 -0500
In-Reply-To: <200711082349.19344.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2007-11-08 at 23:49 +0100, Rafael J. Wysocki wrote:
> On Thursday, 8 of November 2007, Grant Wilson wrote:
> > On Thu, 8 Nov 2007 22:42:21 +0100
> > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > 
> > > On Thursday, 8 of November 2007, Grant Wilson wrote:
> > > > On Thu, 8 Nov 2007 16:53:10 +0100
> > > > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > > > 
> > > > > On Thursday, 8 of November 2007, Grant Wilson wrote:
> > > > > > On Thu, 8 Nov 2007 01:06:21 +0100
> > > > > > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > > > > > 
> > > > > > > On Monday, 5 of November 2007, Grant Wilson wrote:
> > > > > > > > Hi,
> > > > > > > > I got this oops on 2.6.24-rc1-641-gb4f5550:
> > > > > > > 
> > > > > > > (1) Is this reproducible?
> > > > > > > (2) Did it happen previously on your system?
> > > > > > >
> > > > > > > [18073.371126] Unable to handle kernel NULL pointer dereference at 0000000000000120 RIP: 
> > > > > > > [18073.371134]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> > > > > > 
> > > > > > This has now happened twice - the second time was last night when
> > > > > > running 2.6.24-rc2.
> > > > > > 
> > > > > > Here's that second occurrence:
> > > > > > 
> > > > [snip]
> > > > > 
> > > > > Hmm.
> > > > > 
> > > > > Please run "gdb vmlinux" and see what code corresponds to
> > > > > check_preempt_wakeup+0x6e in your kernel.
> > > >
> > > > 
> > > > Dump of assembler code for function check_preempt_wakeup:
> > > 
> > > Well, thanks, but I meant the source code.  Please do "gdb vmlinux" and then
> > > "l *check_preempt_wakeup+0x6e" in gdb.
> > 
> > Here's the requested output:
> > 
> > (gdb) l *check_preempt_wakeup+0x6e
> > 0xffffffff802329ae is in check_preempt_wakeup (kernel/sched_fair.c:668).
> > 663
> > 664     /* Do the two (enqueued) entities belong to the same group ? */
> > 665     static inline int
> > 666     is_same_group(struct sched_entity *se, struct sched_entity *pse)
> > 667     {
> > 668             if (se->cfs_rq == pse->cfs_rq)
> > 669                     return 1;
> > 670
> > 671             return 0;
> > 672     }
> 
> Well, it looks like either se or pse is NULL.
> 
> Ingo, can you please have a look?

Most puzzling this, it should be guaranteed that the top sched_entities
are of the same group, therefore avoiding this loop into NULL. Obviously
something has gone wrong.

Grant, is there anything specific you can tell us about how to reproduce
this?


