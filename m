From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] qed: Replace memset with eth_zero_addr
Date: Tue, 17 Jan 2017 00:21:38 +0530
Message-ID: <1484592698-19747-1-git-send-email-mayhs11saini@gmail.com>
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35914 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdAPSvx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:51:53 -0500
Received: by mail-pf0-f195.google.com with SMTP id 19so3831924pfo.3
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 10:51:53 -0800 (PST)
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
index 6a3727c..778c52c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -1776,7 +1776,7 @@ static int qed_fill_eth_dev_info(struct qed_dev *cdev,
 	qed_fill_dev_info(cdev, &info->common);
 
 	if (IS_VF(cdev))
-		memset(info->common.hw_mac, 0, ETH_ALEN);
+		eth_zero_addr(info->common.hw_mac);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 85b09dd..a15fff4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -1199,7 +1199,7 @@ static void qed_iov_clean_vf(struct qed_hwfn *p_hwfn, u8 vfid)
 		return;
 
 	/* Clear the VF mac */
-	memset(vf_info->mac, 0, ETH_ALEN);
+	eth_zero_addr(vf_info->mac);
 }
 
 static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
@@ -2539,8 +2539,7 @@ static int qed_iov_vf_update_mac_shadow(struct qed_hwfn *p_hwfn,
 		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++) {
 			if (ether_addr_equal(p_vf->shadow_config.macs[i],
 					     p_params->mac)) {
-				memset(p_vf->shadow_config.macs[i], 0,
-				       ETH_ALEN);
+				eth_zero_addr(p_vf->shadow_config.macs[i]);
 				break;
 			}
 		}
@@ -2553,7 +2552,7 @@ static int qed_iov_vf_update_mac_shadow(struct qed_hwfn *p_hwfn,
 	} else if (p_params->opcode == QED_FILTER_REPLACE ||
 		   p_params->opcode == QED_FILTER_FLUSH) {
 		for (i = 0; i < QED_ETH_VF_NUM_MAC_FILTERS; i++)
-			memset(p_vf->shadow_config.macs[i], 0, ETH_ALEN);
+			eth_zero_addr(p_vf->shadow_config.macs[i]);
 	}
 
 	/* List the new MAC address */
-- 
2.7.4
