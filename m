From: Jon Mason <mason@myri.com>
Subject: [PATCH 7/9 v2] myri10ge: misc style cleanups
Date: Mon, 27 Jun 2011 15:56:41 -0500
Message-ID: <20110627205640.GB18978@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
 <1309187108-12715-7-git-send-email-mason@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63627 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754397Ab1F0U4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 16:56:45 -0400
Received: by pwj7 with SMTP id 7so3179255pwj.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 13:56:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1309187108-12715-7-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miscellaneous white space, style, and other cleanups

v2 includes corrections from Joe Perches

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   32 ++++++++++++++------------------
 1 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index b9b80c0..90c8330 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1086,6 +1086,9 @@ static int myri10ge_toggle_relaxed(struct pci_dev *pdev, int on)
 		return 0;
 
 	err = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &ctl);
+	if (err)
+		return 0;
+
 	ret = (ctl & PCI_EXP_DEVCTL_RELAX_EN) >> 4;
 	if (ret != on) {
 		ctl &= ~PCI_EXP_DEVCTL_RELAX_EN;
@@ -1140,20 +1143,19 @@ static void myri10ge_setup_dca(struct myri10ge_priv *mgp)
 		mgp->ss[i].cpu = -1;
 		mgp->ss[i].cached_dca_tag = -1;
 		myri10ge_update_dca(&mgp->ss[i]);
-	 }
+	}
 }
 
 static void myri10ge_teardown_dca(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *pdev = mgp->pdev;
-	int err;
 
 	if (!mgp->dca_enabled)
 		return;
 	mgp->dca_enabled = 0;
 	if (mgp->relaxed_order)
 		myri10ge_toggle_relaxed(pdev, 1);
-	err = dca_remove_requester(&pdev->dev);
+	dca_remove_requester(&pdev->dev);
 }
 
 static int myri10ge_notify_dca_device(struct device *dev, void *data)
@@ -1314,7 +1316,7 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
 
 static inline int
 myri10ge_rx_done(struct myri10ge_slice_state *ss, int len, __wsum csum,
-		 int lro_enabled)
+		 bool lro_enabled)
 {
 	struct myri10ge_priv *mgp = ss->mgp;
 	struct sk_buff *skb;
@@ -1474,11 +1476,9 @@ myri10ge_clean_rx_done(struct myri10ge_slice_state *ss, int budget)
 {
 	struct myri10ge_rx_done *rx_done = &ss->rx_done;
 	struct myri10ge_priv *mgp = ss->mgp;
-
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long rx_ok;
-
 	int idx = rx_done->idx;
 	int cnt = rx_done->cnt;
 	int work_done = 0;
@@ -1531,16 +1531,14 @@ static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
 			mgp->link_state = link_up;
 
 			if (mgp->link_state == MXGEFW_LINK_UP) {
-				if (netif_msg_link(mgp))
-					netdev_info(mgp->dev, "link up\n");
+				netif_info(mgp, link, mgp->dev, "link up\n");
 				netif_carrier_on(mgp->dev);
 				mgp->link_changes++;
 			} else {
-				if (netif_msg_link(mgp))
-					netdev_info(mgp->dev, "link %s\n",
-					    link_up == MXGEFW_LINK_MYRINET ?
+				netif_info(mgp, link, mgp->dev, "link %s\n",
+					   (link_up == MXGEFW_LINK_MYRINET ?
 					    "mismatch (Myrinet detected)" :
-					    "down");
+					    "down"));
 				netif_carrier_off(mgp->dev);
 				mgp->link_changes++;
 			}
@@ -1621,7 +1619,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 		if (send_done_count != tx->pkt_done)
 			myri10ge_tx_done(ss, (int)send_done_count);
 		if (unlikely(i > myri10ge_max_irq_loops)) {
-			netdev_err(mgp->dev, "irq stuck?\n");
+			netdev_warn(mgp->dev, "irq stuck?\n");
 			stats->valid = 0;
 			schedule_work(&mgp->watchdog_work);
 		}
@@ -1785,9 +1783,8 @@ static const char myri10ge_gstrings_slice_stats[][ETH_GSTRING_LEN] = {
 	"----------- slice ---------",
 	"tx_pkt_start", "tx_pkt_done", "tx_req", "tx_done",
 	"rx_small_cnt", "rx_big_cnt",
-	"wake_queue", "stop_queue", "tx_linearized", "LRO aggregated",
-	    "LRO flushed",
-	"LRO avg aggr", "LRO no_desc"
+	"wake_queue", "stop_queue", "tx_linearized",
+	"LRO aggregated", "LRO flushed", "LRO avg aggr", "LRO no_desc",
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -3329,7 +3326,6 @@ abort:
 	/* fall back to using the unaligned firmware */
 	mgp->tx_boundary = 2048;
 	set_fw_name(mgp, myri10ge_fw_unaligned, false);
-
 }
 
 static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
@@ -3715,8 +3711,8 @@ static void myri10ge_free_slices(struct myri10ge_priv *mgp)
 			dma_free_coherent(&pdev->dev, bytes,
 					  ss->fw_stats, ss->fw_stats_bus);
 			ss->fw_stats = NULL;
-			netif_napi_del(&ss->napi);
 		}
+		netif_napi_del(&ss->napi);
 	}
 	kfree(mgp->ss);
 	mgp->ss = NULL;
-- 
1.7.5.4

