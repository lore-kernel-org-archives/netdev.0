From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 18:43:27 -0700
Message-ID: <1237427007.8204.55.camel@quadrophenia.thebigcorporation.com>
References: <49C16D7C.3080003@novell.com>
	 <20090318.180355.228447835.davem@davemloft.net>
	 <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>
	 <20090318.181713.62394874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, vernux@us.ibm.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, pmullaney@novell.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <20090318.181713.62394874.davem@davemloft.net>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-03-18 at 18:17 -0700, David Miller wrote:
> From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
> Date: Wed, 18 Mar 2009 18:13:11 -0700
> 
> > On Wed, 2009-03-18 at 18:03 -0700, David Miller wrote:
> > > From: Gregory Haskins <ghaskins@novell.com>
> > > Date: Wed, 18 Mar 2009 17:54:04 -0400
> > > 
> > > > Note that -rt doesnt typically context-switch under contention anymore
> > > > since we introduced adaptive-locks.  Also note that the contention
> > > > against the lock is still contention, regardless of whether you have -rt
> > > > or not.  Its just that the slow-path to handle the contended case for
> > > > -rt is more expensive than mainline.  However, once you have the
> > > > contention as stated, you have already lost.
> > > 
> > > First, contention is not implicitly a bad thing.
> >
> > Its a bad thing when it does not scale.
> 
> You have only one pipe to shove packets into in this case, and for
> your workload multiple cpus are going to be trying to stuff a single
> packet at a time from a single UDP send request.
> 
> There is no added parallelism you can create for that kind of workload
> on that kind of hardware.
> 

Do we have to rule-out per-CPU queues, that aggregate into a master
queue in a batch-wise manner? 

I speculate that might reduce the lock contention by a factor of NCPUs.
I cannot say this would be enough to mitigate the consequent overhead
penalty. 

> It is one of the issues addressed by multiqueue.

Properly tuned adaptive locks, would theoretically perform
near-optimally compared to the mainline case, and would provide better
CPU utilization on very large parallel architectures. 

Sven

