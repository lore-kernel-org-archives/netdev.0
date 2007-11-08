From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.24-rc1-gb4f5550 oops
Date: Thu, 8 Nov 2007 23:49:18 +0100
Message-ID: <200711082349.19344.rjw@sisk.pl>
References: <20071105061158.3174d24d@worthy.swandive.local> <200711082242.21869.rjw@sisk.pl> <20071108221951.71224bd8@worthy.swandive.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: Grant Wilson <grant.wilson@zen.co.uk>, Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761602AbXKHWcf@vger.kernel.org>
In-Reply-To: <20071108221951.71224bd8@worthy.swandive.local>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 8 of November 2007, Grant Wilson wrote:
> On Thu, 8 Nov 2007 22:42:21 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > On Thursday, 8 of November 2007, Grant Wilson wrote:
> > > On Thu, 8 Nov 2007 16:53:10 +0100
> > > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > > 
> > > > On Thursday, 8 of November 2007, Grant Wilson wrote:
> > > > > On Thu, 8 Nov 2007 01:06:21 +0100
> > > > > "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> > > > > 
> > > > > > On Monday, 5 of November 2007, Grant Wilson wrote:
> > > > > > > Hi,
> > > > > > > I got this oops on 2.6.24-rc1-641-gb4f5550:
> > > > > > 
> > > > > > (1) Is this reproducible?
> > > > > > (2) Did it happen previously on your system?
> > > > > >
> > > > > > [18073.371126] Unable to handle kernel NULL pointer dereference at 0000000000000120 RIP: 
> > > > > > [18073.371134]  [<ffffffff8023572e>] check_preempt_wakeup+0x6e/0x110
> > > > > 
> > > > > This has now happened twice - the second time was last night when
> > > > > running 2.6.24-rc2.
> > > > > 
> > > > > Here's that second occurrence:
> > > > > 
> > > [snip]
> > > > 
> > > > Hmm.
> > > > 
> > > > Please run "gdb vmlinux" and see what code corresponds to
> > > > check_preempt_wakeup+0x6e in your kernel.
> > >
> > > 
> > > Dump of assembler code for function check_preempt_wakeup:
> > 
> > Well, thanks, but I meant the source code.  Please do "gdb vmlinux" and then
> > "l *check_preempt_wakeup+0x6e" in gdb.
> 
> Here's the requested output:
> 
> (gdb) l *check_preempt_wakeup+0x6e
> 0xffffffff802329ae is in check_preempt_wakeup (kernel/sched_fair.c:668).
> 663
> 664     /* Do the two (enqueued) entities belong to the same group ? */
> 665     static inline int
> 666     is_same_group(struct sched_entity *se, struct sched_entity *pse)
> 667     {
> 668             if (se->cfs_rq == pse->cfs_rq)
> 669                     return 1;
> 670
> 671             return 0;
> 672     }

Well, it looks like either se or pse is NULL.

Ingo, can you please have a look?

Thanks,
Rafael
