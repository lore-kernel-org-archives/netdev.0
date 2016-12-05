From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 01/28] bnxt_en: Add bnxt_set_max_func_irqs().
Date: Sun,  4 Dec 2016 22:38:05 -0800
Message-ID: <1480919912-1079-2-git-send-email-selvin.xavier@broadcom.com>
References: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480919912-1079-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

By refactoring existing code into this new function.  The new function
will be used in subsequent patches.

Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Signed-off-by: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 17 +++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e8ab5fd..6cdfe3e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4743,6 +4743,16 @@ static int bnxt_trim_rings(struct bnxt *bp, int *rx, int *tx, int max,
 	return 0;
 }
 
+void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max_irqs)
+{
+	if (BNXT_PF(bp))
+		bp->pf.max_irqs = max_irqs;
+#if defined(CONFIG_BNXT_SRIOV)
+	else
+		bp->vf.max_irqs = max_irqs;
+#endif
+}
+
 static int bnxt_setup_msix(struct bnxt *bp)
 {
 	struct msix_entry *msix_ent;
@@ -6949,12 +6959,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	bnxt_set_tpa_flags(bp);
 	bnxt_set_ring_params(bp);
-	if (BNXT_PF(bp))
-		bp->pf.max_irqs = max_irqs;
-#if defined(CONFIG_BNXT_SRIOV)
-	else
-		bp->vf.max_irqs = max_irqs;
-#endif
+	bnxt_set_max_func_irqs(bp, max_irqs);
 	bnxt_set_dflt_rings(bp);
 
 	/* Default RSS hash cfg. */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b4abc1b..8327d0d 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1235,6 +1235,7 @@ int hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
 int bnxt_hwrm_func_qcaps(struct bnxt *);
+void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
 int bnxt_hwrm_set_pause(struct bnxt *);
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
