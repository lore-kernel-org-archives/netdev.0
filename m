From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [tip:irq/core PATCH] genirq: fix null pointer reference in
 irq_set_affinity_hint()
Date: Wed, 28 Jan 2015 10:57:39 -0800
Message-ID: <20150128185739.9689.84588.stgit@jbrandeb-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: mingo@kernel.org, netdev@vger.kernel.org, yinghai@kernel.org,
	linux-kernel@vger.kernel.org, hpa@zytor.com
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recent set_affinity commit by me introduced some null
pointer dereferences on driver unload, because some drivers
call this function with a NULL argument. This fixes the issue
by just checking for null before setting the affinity mask.

Fixes: e2e64a932556 ("genirq: Set initial affinity in irq_set_affinity_hint()")
Reported-by: Yinghai Lu <yinghai@kernel.org>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: netdev@vger.kernel.org
---
 kernel/irq/manage.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index f038e58..196a06f 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -244,7 +244,8 @@ int irq_set_affinity_hint(unsigned int irq, const struct cpumask *m)
 	desc->affinity_hint = m;
 	irq_put_desc_unlock(desc, flags);
 	/* set the initial affinity to prevent every interrupt being on CPU0 */
-	__irq_set_affinity(irq, m, false);
+	if (m)
+		__irq_set_affinity(irq, m, false);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(irq_set_affinity_hint);
