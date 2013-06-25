From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v2 40/45] powerpc,
 irq: Use GFP_ATOMIC allocations in atomic context
Date: Wed, 26 Jun 2013 02:03:11 +0530
Message-ID: <20130625203310.16593.6214.stgit@srivatsabhat.in.ibm.com>
References: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, sbw@mit.edu, fweisbec@gmail.com,
	zhong@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Ian Munsie <imunsie@au1.ibm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Li Zhong <zhong@linux.vnet.ibm.com>,
	linuxppc-dev@lists.ozlabs.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org, laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625202452.16593.22810.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function migrate_irqs() is called with interrupts disabled
and hence its not safe to do GFP_KERNEL allocations inside it,
because they can sleep. So change the gfp mask to GFP_ATOMIC.

Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michael Ellerman <michael@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Ian Munsie <imunsie@au1.ibm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Michael Ellerman <michael@ellerman.id.au>
Cc: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/irq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
index ea185e0..ca39bac 100644
--- a/arch/powerpc/kernel/irq.c
+++ b/arch/powerpc/kernel/irq.c
@@ -412,7 +412,7 @@ void migrate_irqs(void)
 	cpumask_var_t mask;
 	const struct cpumask *map = cpu_online_mask;
 
-	alloc_cpumask_var(&mask, GFP_KERNEL);
+	alloc_cpumask_var(&mask, GFP_ATOMIC);
 
 	for_each_irq_desc(irq, desc) {
 		struct irq_data *data;
