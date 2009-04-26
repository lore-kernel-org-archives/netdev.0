From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Sun, 26 Apr 2009 13:27:17 +0200
Message-ID: <20090426112717.GE10391@elte.hu>
References: <20090426052340.GA24931@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756291AbZDZL32@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090426052340.GA24931@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Second cut of "big hammer" expedited RCU grace periods, but only 
> for rcu_bh.  This creates another softirq vector, so that entering 
> this softirq vector will have forced an rcu_bh quiescent state (as 
> noted by Dave Miller).  Use smp_call_function() to invoke 
> raise_softirq() on all CPUs in order to cause this to happen.  
> Track the CPUs that have passed through a quiescent state (or gone 
> offline) with a cpumask.

hm, i'm still asking whether doing this would be simpler via a 
reschedule vector - which not only is an existing facility but also 
forces all RCU domains through a quiescent state - not just bh-RCU 
participants.

Triggering a new softirq is in no way simpler that doing an SMP 
cross-call - in fact softirqs are a finite resource so using some 
other facility would be preferred.

Am i missing something?

	Ingo
