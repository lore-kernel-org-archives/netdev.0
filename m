From: Ingo Molnar <mingo@elte.hu>
Subject: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Sun, 27 Mar 2005 11:15:24 +0200
Message-ID: <20050327091524.GA23215@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


i got one such message:

 KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (126)

this was on a box that is DSL connected and thus gets lots of trash 
packets over the wire. It is running -RT ontop of 2.6.12-rc1, and got 
this message after 2 days of uptime.

There was no apparent bad side-effect after this happened - no crash, no 
hung applications, no hung connections, the box is still up and running 
fine. The message is not reproducible, unfortunately. Never saw this 
message with 2.6.11-ish kernels on the same box.

since the locking is so different under PREEMPT_RT it may very well be
caused by PREEMPT_RT itself - but it could also be some real bug that
only triggers under PREEMPT_RT. Based on current bug trends i'd say the
likelyhood is 70% for this to be a genuine upstream bug, and 30% for
this to be a PREEMPT_RT artifact. (These days most PREEMPT_RT artifacts 
get detected by PREEMPT_RT's own debugging features - and all of them 
were enabled on this box. Due to its preemption model, PREEMPT_RT is 
pretty good at catching races that are near-impossible to trigger on the 
stock kernel. It already caught more than a dozen such upstream races in 
various kernel subsystems.)

	Ingo
