From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Fri, 28 Jun 2002 12:56:31 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <afif9f$oe1$2@main.gmane.org>
References: <20020609.213150.32126725.davem@redhat.com> <3D042F8F.72764243@mvista.com> <3D120EAE.5A0D365E@mvista.com> <20020620.173805.55219901.davem@redhat.com> <3D133538.60B6810C@mvista.com> <20020622025551.A1919@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, pekkas@netcore.fi,
   andrew.r.cress@intel.com
Return-path: <owner-netdev@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
List-Id: netdev.vger.kernel.org

We finally found the problem.  I want to thank the folks who
gave any thought and/or feedback to us, particularly Alexey
and David.

For what its worth we tracked it down to the kernel memory
allocation routines allocating the same buffer to two
different network requesters.  This in turn was caused by a
basic flaw in the preemption code that preempted on
spin_unlock, REGARDLESS OF THE STATE OF THE INTERRUPT
SYSTEM.
-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml
