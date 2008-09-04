From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] Return value from schedule()
Date: Thu, 4 Sep 2008 10:30:49 -0700
Message-ID: <20080904103049.01f748d9@infradead.org>
References: <20080827204626.4b65862f@extreme>
	<20080828111323.GI7908@solarflare.com>
	<20080903155713.7fab2e19@extreme>
	<20080904160739.GK2772@parisc-linux.org>
	<20080904161424.GA23042@elte.hu>
	<20080904162111.GM2772@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080904162111.GM2772@parisc-linux.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Sep 2008 10:21:11 -0600
Matthew Wilcox <matthew@wil.cx> wrote:

> On Thu, Sep 04, 2008 at 06:14:24PM +0200, Ingo Molnar wrote:
> > > If schedule() returned whether or not it had scheduled another
> > > task, we could do something like:
> > > 
> > > 		if (!schedule())
> > > 			udelay(10);
> > 
> > hm, i'm not really sure - this really just seems to be a higher
> > prio variant of yield() combined with some weird code. Do we really
> > want to promote such arguably broken behavior? If there's any
> > chance of any polling to take a material amount of CPU time it
> > should be event driven to begin with.
> 
> Oh, I'm not concerned about CPU utilisation, I'm concerned about PCI
> bus utilisation.  Perhaps I'd like a yield_timeout() function instead
> where I say that I'd like to not run for at least 10 microseconds?
> 
> Can we do that, or are we still jiffie-based there?
> 

use schedule_hrtimerout() for this (hopefully will be in 2.6.28);
see this weeks LWN for an article describing it
