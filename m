From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 13/13] bnx2x: Correct PFC disablement
Date: Sun, 2 Dec 2012 16:05:57 +0200
Message-ID: <1354457157-4730-14-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1627 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399Ab2LBOF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:29 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

bnx2x driver could only have enabled pfc via usage of dcbnl; now, it can
also correctly disable it.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index c8c0340..10bc093 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -2052,10 +2052,13 @@ static void bnx2x_dcbnl_set_pfc_cfg(struct net_device *netdev, int prio,
 	if (!bnx2x_dcbnl_set_valid(bp) || prio >= MAX_PFC_PRIORITIES)
 		return;
 
-	bp->dcbx_config_params.admin_pfc_bitmap |= ((setting ? 1 : 0) << prio);
 
-	if (setting)
+	if (setting) {
+		bp->dcbx_config_params.admin_pfc_bitmap |= (1 << prio);
 		bp->dcbx_config_params.admin_pfc_tx_enable = 1;
+	} else {
+		bp->dcbx_config_params.admin_pfc_bitmap &= ~(1 << prio);
+	}
 }
 
 static void bnx2x_dcbnl_get_pfc_cfg(struct net_device *netdev, int prio,
-- 
1.7.1
