From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] Return value from schedule()
Date: Fri, 05 Sep 2008 09:40:40 +0200
Message-ID: <1220600440.7080.2.camel@twins.programming.kicks-ass.net>
References: <20080827204626.4b65862f@extreme>
	 <20080828111323.GI7908@solarflare.com> <20080903155713.7fab2e19@extreme>
	 <20080904160739.GK2772@parisc-linux.org> <20080904161424.GA23042@elte.hu>
	 <20080904162111.GM2772@parisc-linux.org>
	 <20080904103049.01f748d9@infradead.org>
	 <20080904174845.GN2772@parisc-linux.org>  <20080904120522.6d5fdf8d@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080904120522.6d5fdf8d@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-09-04 at 12:05 -0700, Stephen Hemminger wrote:
> On Thu, 4 Sep 2008 11:48:45 -0600
> Matthew Wilcox <matthew@wil.cx> wrote:
> 
> > On Thu, Sep 04, 2008 at 10:30:49AM -0700, Arjan van de Ven wrote:
> > > use schedule_hrtimerout() for this (hopefully will be in 2.6.28);
> > > see this weeks LWN for an article describing it
> > 
> > OK, so something like:
> > 
> > 	struct timespec ts = { 0, 10 * 1000 };
> > 
> > 	set_task_state(TASK_INTERRUPTIBLE);
> > 	schedule_hrtimeout(&ts, HRTIMER_MODE_REL);
> > 	if (fatal_signal_pending())
> > 		return -EINTR;
> > 
> > should do the trick.
> > 
> 
> Never mind, I changed it to just yield() in revision.

Gah, not another yield in the network code we have to figure out wtf its
meant to do.
