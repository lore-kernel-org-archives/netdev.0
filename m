From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] qed: Replace memset with eth_zero_addr
Date: Tue, 17 Jan 2017 07:35:04 +0530
Message-ID: <1484618704-3396-1-git-send-email-mayhs11saini@gmail.com>
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36549 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdAQCFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 21:05:24 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so6603469pgf.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 18:05:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_zero_addr to assign zero address to the given address array
instead of memset when the second argument in memset is address
of zero. Also, it makes the code clearer

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c    | 2 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index c92a850..7520eb3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1846,7 +1846,7 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	qed_fill_dev_info(cdev, &info->common);
 
 	if (IS_VF(cdev))
-		memset(info->common.hw_mac, 0, ETH_ALEN);
+		eth_zero_addr(info->common.hw_mac);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index b121364..3f4bf31 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1224,7 +1224,7 @@ static void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
 		return;
 
 	/* Clear the VF mac */
-	memset(vf_info->mac, 0, ETH_ALEN);
+	eth_zero_addr(vf_info->mac);
 
 	vf_info->rx_accept_mode = 0;
 	vf_info->tx_accept_mode = 0;
@@ -2626,8 +2626,7 @@ static int qed_iov_vf_update_mac_shadow(struct qed_hwfn *p_hwfn,
 		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++) {
 			if (ether_addr_equal(p_vf->shadow_config.macs[i],
 					     p_params->mac)) {
-				memset(p_vf->shadow_config.macs[i], 0,
-				       ETH_ALEN);
+				eth_zero_addr(p_vf->shadow_config.macs[i]);
 				break;
 			}
 		}
@@ -2640,7 +2639,7 @@ static int qed_iov_vf_update_mac_shadow(struct qed_hwfn *p_hwfn,
 	} else if (p_params->opcode == QED_FILTER_REPLACE ||
 		   p_params->opcode == QED_FILTER_FLUSH) {
 		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++)
-			memset(p_vf->shadow_config.macs[i], 0, ETH_ALEN);
+			eth_zero_addr(p_vf->shadow_config.macs[i]);
 	}
 
 	/* List the new MAC address */
-- 
2.7.4
