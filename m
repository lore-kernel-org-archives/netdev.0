From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] Return value from schedule()
Date: Thu, 4 Sep 2008 11:48:45 -0600
Message-ID: <20080904174845.GN2772@parisc-linux.org>
References: <20080827204626.4b65862f@extreme> <20080828111323.GI7908@solarflare.com> <20080903155713.7fab2e19@extreme> <20080904160739.GK2772@parisc-linux.org> <20080904161424.GA23042@elte.hu> <20080904162111.GM2772@parisc-linux.org> <20080904103049.01f748d9@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080904103049.01f748d9@infradead.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2008 at 10:30:49AM -0700, Arjan van de Ven wrote:
> use schedule_hrtimerout() for this (hopefully will be in 2.6.28);
> see this weeks LWN for an article describing it

OK, so something like:

	struct timespec ts = { 0, 10 * 1000 };

	set_task_state(TASK_INTERRUPTIBLE);
	schedule_hrtimeout(&ts, HRTIMER_MODE_REL);
	if (fatal_signal_pending())
		return -EINTR;

should do the trick.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
