From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Mon, 18 May 2009 00:02:23 +0400
Message-ID: <20090517200223.GA31029@ioremap.net>
References: <20090517191141.GA25915@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulus@samba.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090517191141.GA25915@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Sun, May 17, 2009 at 12:11:41PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> Fifth cut of "big hammer" expedited RCU grace periods.  This uses per-CPU
> kthreads that are scheduled in parallel by a call to smp_call_function()
> by yet another kthread.  The synchronize_sched(), synchronize_rcu(),
> and synchronize_bh() primitives wake this kthread up and then wait for
> it to force the grace period.

I'm curious, but doesn't the fact that registered 'barrier' callback is
invoked mean grace period completion? I.e. why to bother with
rescheduling, waiting for thread to complete and so on, when we only
care in the fact that 'barrier' callback is invoked, and thus all
previous ones are completed?
Or it is done just for the simplicity, since all rescheduling machinery
already manages the rcu bits correctly, so you do not want to put it
directly into 'barrier' callback?

-- 
	Evgeniy Polyakov
