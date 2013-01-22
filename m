From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 14/45] rcu,
 CPU hotplug: Fix comment referring to stop_machine()
Date: Tue, 22 Jan 2013 13:06:34 +0530
Message-ID: <20130122073630.13822.99359.stgit@srivatsabhat.in.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, srivatsa.bhat@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't refer to stop_machine() in the CPU hotplug path, since we are going
to get rid of it. Also, move the comment referring to callback adoption
to the CPU_DEAD case, because that's where it happens now.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 kernel/rcutree.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/kernel/rcutree.c b/kernel/rcutree.c
index e441b77..ac94474 100644
--- a/kernel/rcutree.c
+++ b/kernel/rcutree.c
@@ -2827,11 +2827,6 @@ static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
 		break;
 	case CPU_DYING:
 	case CPU_DYING_FROZEN:
-		/*
-		 * The whole machine is "stopped" except this CPU, so we can
-		 * touch any data without introducing corruption. We send the
-		 * dying CPU's callbacks to an arbitrarily chosen online CPU.
-		 */
 		for_each_rcu_flavor(rsp)
 			rcu_cleanup_dying_cpu(rsp);
 		rcu_cleanup_after_idle(cpu);
@@ -2840,6 +2835,10 @@ static int __cpuinit rcu_cpu_notify(struct notifier_block *self,
 	case CPU_DEAD_FROZEN:
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
+		/*
+		 * We send the dead CPU's callbacks to an arbitrarily chosen
+		 * online CPU.
+		 */
 		for_each_rcu_flavor(rsp)
 			rcu_cleanup_dead_cpu(cpu, rsp);
 		break;

