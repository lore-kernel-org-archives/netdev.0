From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v3 08/45] CPU hotplug: Expose the new debug config option
Date: Fri, 28 Jun 2013 01:23:58 +0530
Message-ID: <20130627195358.29830.48847.stgit@srivatsabhat.in.ibm.com>
References: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paul.mckenney@linaro.org>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Michel Lespinasse <walken@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, David.Laight@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130627195136.29830.10445.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have all the pieces of the CPU hotplug debug infrastructure
in place, expose the feature by growing a new Kconfig option,
CONFIG_DEBUG_HOTPLUG_CPU.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Paul E. McKenney" <paul.mckenney@linaro.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 lib/Kconfig.debug |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 7154f79..42e17f0 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -512,6 +512,14 @@ config DEBUG_PREEMPT
 	  if kernel code uses it in a preemption-unsafe way. Also, the kernel
 	  will detect preemption count underflows.
 
+config DEBUG_HOTPLUG_CPU
+	bool "Debug CPU hotplug"
+	depends on HOTPLUG_CPU
+	help
+	  If you say Y here, the kernel will check all the accesses of
+	  cpu_online_mask from atomic contexts, and will print warnings if
+	  the task lacks appropriate synchronization with CPU hotplug.
+
 config DEBUG_RT_MUTEXES
 	bool "RT Mutex debugging, deadlock detection"
 	depends on DEBUG_KERNEL && RT_MUTEXES
