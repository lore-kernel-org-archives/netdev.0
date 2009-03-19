From: David Miller <davem@davemloft.net>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 18:17:13 -0700 (PDT)
Message-ID: <20090318.181713.62394874.davem@davemloft.net>
References: <49C16D7C.3080003@novell.com>
	<20090318.180355.228447835.davem@davemloft.net>
	<1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ghaskins@novell.com, vernux@us.ibm.com, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org, pmullaney@novell.com
To: sven@thebigcorporation.com
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <1237425191.8204.41.camel@quadrophenia.thebigcorporation.com>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven-Thorsten Dietrich <sven@thebigcorporation.com>
Date: Wed, 18 Mar 2009 18:13:11 -0700

> On Wed, 2009-03-18 at 18:03 -0700, David Miller wrote:
> > From: Gregory Haskins <ghaskins@novell.com>
> > Date: Wed, 18 Mar 2009 17:54:04 -0400
> > 
> > > Note that -rt doesnt typically context-switch under contention anymore
> > > since we introduced adaptive-locks.  Also note that the contention
> > > against the lock is still contention, regardless of whether you have -rt
> > > or not.  Its just that the slow-path to handle the contended case for
> > > -rt is more expensive than mainline.  However, once you have the
> > > contention as stated, you have already lost.
> > 
> > First, contention is not implicitly a bad thing.
>
> Its a bad thing when it does not scale.

You have only one pipe to shove packets into in this case, and for
your workload multiple cpus are going to be trying to stuff a single
packet at a time from a single UDP send request.

There is no added parallelism you can create for that kind of workload
on that kind of hardware.

It is one of the issues addressed by multiqueue.
