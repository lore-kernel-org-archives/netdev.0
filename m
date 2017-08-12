From: Juergen Gross <jgross@suse.com>
Subject: [PATCH] net/i40e: use cpumask_copy() for assigning cpumask
Date: Sat, 12 Aug 2017 18:09:46 +0200
Message-ID: <20170812160946.2278-1-jgross@suse.com>
Cc: jeffrey.t.kirsher@intel.com, Juergen Gross <jgross@suse.com>,
        stable@vger.kernel.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using direct assignment for a cpumask is wrong, cpumask_copy() should
be used instead.

Cc: stable@vger.kernel.org
Signed-off-by: Juergen Gross <jgross@suse.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2db93d3f6d23..c0e42d162c7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3495,7 +3495,7 @@ static void i40e_irq_affinity_notify(struct irq_affinity_notify *notify,
 	struct i40e_q_vector *q_vector =
 		container_of(notify, struct i40e_q_vector, affinity_notify);
 
-	q_vector->affinity_mask = *mask;
+	cpumask_copy(&q_vector->affinity_mask, mask);
 }
 
 /**
-- 
2.12.3
