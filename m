From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 1/4] - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:47:58 +0100
Message-ID: <20061130064758.GD2003@elte.hu>
References: <2f14bf623344.456de60a@fnal.gov> <20061129.181950.31643130.davem@davemloft.net> <20061130061758.GA2003@elte.hu> <20061129.223055.05159325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wenji@fnal.gov, akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:49821 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1758001AbWK3GuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 01:50:11 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061129.223055.05159325.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> > yeah, i like this one. If the problem is "too long locked section", 
> > then the most natural solution is to "break up the lock", not to 
> > "boost the priority of the lock-holding task" (which is what the 
> > proposed patch does).
> 
> Ingo you're mis-read the problem :-)

yeah, the problem isnt too long locked section but "too much time spent 
holding a lock" and hence opening up ourselves to possible negative 
side-effects of the scheduler's fairness algorithm when it forces a 
preemption of that process context with that lock held (and forcing all 
subsequent packets to be backlogged).

but please read my last mail - i think i'm slowly starting to wake up 
;-) I dont think there is any real problem: a tweak to the scheduler 
that in essence gives TCP-using tasks a preference changes the balance 
of workloads. Such an explicit tweak is possible already.

furthermore, the tweak allows the shifting of processing from a 
prioritized process context into a highest-priority softirq context. 
(it's not proven that there is any significant /net win/ of performance: 
all that was proven is that if we shift TCP processing from process 
context into softirq context then TCP throughput of that otherwise 
penalized process context increases.)

	Ingo
