From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH v5 38/45] parisc: Use get/put_online_cpus_atomic() to prevent
 CPU offline
Date: Tue, 22 Jan 2013 13:13:39 +0530
Message-ID: <20130122074335.13822.41002.stgit@srivatsabhat.in.ibm.com>
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
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once stop_machine() is gone from the CPU offline path, we won't be able to
depend on preempt_disable() or local_irq_disable() to prevent CPUs from
going offline from under us.

Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
while invoking from atomic context.

Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: linux-parisc@vger.kernel.org
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 arch/parisc/kernel/smp.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/parisc/kernel/smp.c b/arch/parisc/kernel/smp.c
index 6266730..f7851b7 100644
--- a/arch/parisc/kernel/smp.c
+++ b/arch/parisc/kernel/smp.c
@@ -229,11 +229,13 @@ static inline void
 send_IPI_allbutself(enum ipi_message_type op)
 {
 	int i;
-	
+
+	get_online_cpus_atomic();
 	for_each_online_cpu(i) {
 		if (i != smp_processor_id())
 			send_IPI_single(i, op);
 	}
+	put_online_cpus_atomic();
 }
 
 

