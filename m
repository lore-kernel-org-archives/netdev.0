From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: RCU : various patches  [0/5]
Date: Sun, 8 Aug 2004 00:45:37 +0530
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040807191536.GA3936@in.ibm.com>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266127AbUHFTSZ@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

This is a series of patches that are currently in my tree. These apply
on 2.6.8-rc3-mm1 (on top the earlier 3 patches in -mm). Of these,
the first one is a cleanup to avoid percpu data address calculations
and also prepration for call_rcu_bh(). The call-rcu-bh patches
introduce a separate RCU mechanism for softirq handlers with
handler completion as another quiescent state and use it
in route cache. This avoids the dst cache overflow problems 
Robert Olsson was seeing during his router DoS testing.
All this work happened after a long private email discussion
some months ago involving Alexey, Robert, Dave Miller and some of us.
I am publishing the work so that people can test it. It would
be nice to give the entire stack a spin in -mm. 

The remaining two patches are from Paul that documents RCU apis
and hides smp_read_barrier_depends() using a simple macro -
rcu_dereference().

I have tested the call-rcu-bh stuff with pktgen and saw no
route cache overflows. The complete stack is also sanity tested.

Thanks
Dipankar
