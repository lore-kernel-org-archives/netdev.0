From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH 4/6] ath6kl: get rid of AR_DBG_LVL_CHECK()
Date: Thu, 05 Jan 2012 01:09:22 +0200
Message-ID: <20120104230921.32306.63985.stgit@x201>
References: <20120104230429.32306.75965.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath6kl-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120104230429.32306.75965.stgit@x201>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We don't need it as debug calls already have a log level and compiler
should be smart enough to optimise away the code when ath6kl debug code
is not enabled. Also it makes it easier to abstract core code to
ath6kl_core.ko.

Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/debug.c |   35 ++++++++++++++-----------------
 drivers/net/wireless/ath/ath6kl/debug.h |    2 --
 drivers/net/wireless/ath/ath6kl/hif.c   |    5 ++--
 drivers/net/wireless/ath/ath6kl/wmi.c   |    3 ---
 4 files changed, 18 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index eb808b4..0d77129 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -82,31 +82,31 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 			   struct ath6kl_irq_enable_reg *irq_enable_reg)
 {
 
-	ath6kl_dbg(ATH6KL_DBG_ANY, ("<------- Register Table -------->\n"));
+	ath6kl_dbg(ATH6KL_DBG_IRQ, ("<------- Register Table -------->\n"));
 
 	if (irq_proc_reg != NULL) {
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			"Host Int status:           0x%x\n",
 			irq_proc_reg->host_int_status);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "CPU Int status:            0x%x\n",
 			irq_proc_reg->cpu_int_status);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Error Int status:          0x%x\n",
 			irq_proc_reg->error_int_status);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Counter Int status:        0x%x\n",
 			irq_proc_reg->counter_int_status);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Mbox Frame:                0x%x\n",
 			irq_proc_reg->mbox_frame);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Rx Lookahead Valid:        0x%x\n",
 			irq_proc_reg->rx_lkahd_valid);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Rx Lookahead 0:            0x%x\n",
 			irq_proc_reg->rx_lkahd[0]);
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			   "Rx Lookahead 1:            0x%x\n",
 			irq_proc_reg->rx_lkahd[1]);
 
@@ -115,16 +115,16 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 			 * If the target supports GMBOX hardware, dump some
 			 * additional state.
 			 */
-			ath6kl_dbg(ATH6KL_DBG_ANY,
+			ath6kl_dbg(ATH6KL_DBG_IRQ,
 				"GMBOX Host Int status 2:   0x%x\n",
 				irq_proc_reg->host_int_status2);
-			ath6kl_dbg(ATH6KL_DBG_ANY,
+			ath6kl_dbg(ATH6KL_DBG_IRQ,
 				"GMBOX RX Avail:            0x%x\n",
 				irq_proc_reg->gmbox_rx_avail);
-			ath6kl_dbg(ATH6KL_DBG_ANY,
+			ath6kl_dbg(ATH6KL_DBG_IRQ,
 				"GMBOX lookahead alias 0:   0x%x\n",
 				irq_proc_reg->rx_gmbox_lkahd_alias[0]);
-			ath6kl_dbg(ATH6KL_DBG_ANY,
+			ath6kl_dbg(ATH6KL_DBG_IRQ,
 				"GMBOX lookahead alias 1:   0x%x\n",
 				irq_proc_reg->rx_gmbox_lkahd_alias[1]);
 		}
@@ -132,13 +132,13 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 	}
 
 	if (irq_enable_reg != NULL) {
-		ath6kl_dbg(ATH6KL_DBG_ANY,
+		ath6kl_dbg(ATH6KL_DBG_IRQ,
 			"Int status Enable:         0x%x\n",
 			irq_enable_reg->int_status_en);
-		ath6kl_dbg(ATH6KL_DBG_ANY, "Counter Int status Enable: 0x%x\n",
+		ath6kl_dbg(ATH6KL_DBG_IRQ, "Counter Int status Enable: 0x%x\n",
 			irq_enable_reg->cntr_int_status_en);
 	}
-	ath6kl_dbg(ATH6KL_DBG_ANY, "<------------------------------->\n");
+	ath6kl_dbg(ATH6KL_DBG_IRQ, "<------------------------------->\n");
 }
 
 static void dump_cred_dist(struct htc_endpoint_credit_dist *ep_dist)
@@ -175,9 +175,6 @@ void dump_cred_dist_stats(struct htc_target *target)
 {
 	struct htc_endpoint_credit_dist *ep_list;
 
-	if (!AR_DBG_LVL_CHECK(ATH6KL_DBG_CREDIT))
-		return;
-
 	list_for_each_entry(ep_list, &target->cred_dist_list, list)
 		dump_cred_dist(ep_list);
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index e569c65..cb21d91 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -56,8 +56,6 @@ int ath6kl_printk(const char *level, const char *fmt, ...);
 #define ath6kl_warn(fmt, ...)					\
 	ath6kl_printk(KERN_WARNING, fmt, ##__VA_ARGS__)
 
-#define AR_DBG_LVL_CHECK(mask)	(debug_mask & mask)
-
 enum ath6kl_war {
 	ATH6KL_WAR_INVALID_RATE,
 };
diff --git a/drivers/net/wireless/ath/ath6kl/hif.c b/drivers/net/wireless/ath/ath6kl/hif.c
index 0772ef6..3d26c14 100644
--- a/drivers/net/wireless/ath/ath6kl/hif.c
+++ b/drivers/net/wireless/ath/ath6kl/hif.c
@@ -429,9 +429,8 @@ static int proc_pending_irqs(struct ath6kl_device *dev, bool *done)
 		if (status)
 			goto out;
 
-		if (AR_DBG_LVL_CHECK(ATH6KL_DBG_IRQ))
-			ath6kl_dump_registers(dev, &dev->irq_proc_reg,
-					 &dev->irq_en_reg);
+		ath6kl_dump_registers(dev, &dev->irq_proc_reg,
+				      &dev->irq_en_reg);
 
 		/* Update only those registers that are enabled */
 		host_int_status = dev->irq_proc_reg.host_int_status &
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index f6f2aa2..fbd886a 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -419,9 +419,6 @@ static int ath6kl_wmi_tx_complete_event_rx(u8 *datap, int len)
 	ath6kl_dbg(ATH6KL_DBG_WMI, "comp: %d %d %d\n",
 		   evt->num_msg, evt->msg_len, evt->msg_type);
 
-	if (!AR_DBG_LVL_CHECK(ATH6KL_DBG_WMI))
-		return 0;
