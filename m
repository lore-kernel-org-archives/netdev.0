From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH 2/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 09:14:37 +0530
Message-ID: <1484538277-21376-2-git-send-email-mayhs11saini@gmail.com>
References: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
Cc: Ariel.Elior@cavium.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36620 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdAPDpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 22:45:03 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so4210371pgf.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 19:45:03 -0800 (PST)
In-Reply-To: <1484538277-21376-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_zero_addr to assign zero address to the given address array
instead of memset when the second argument in memset is address
of zero. Also, it makes the code clearer

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

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
