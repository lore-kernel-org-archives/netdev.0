From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH 3/7] bnx2x: prevent timeouts when using PFC
Date: Mon, 10 Sep 2012 18:48:51 +0300
Message-ID: <1347292135-30250-4-git-send-email-yuvalmin@broadcom.com>
References: <1347292135-30250-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2741 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab2IJQ1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:27:20 -0400
In-Reply-To: <1347292135-30250-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Prevent updating the xmac PFC configuration when using a link speed
slower than 10G -the umac block is responsible for 1G or slower connections,
therefore it is possible the xmac block is reset when connection is slower.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index f4beb46..40a7b8d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -2667,9 +2667,11 @@ int bnx2x_update_pfc(struct link_params *params,
 		return bnx2x_status;
 
 	DP(NETIF_MSG_LINK, "About to update PFC in BMAC\n");
-	if (CHIP_IS_E3(bp))
-		bnx2x_update_pfc_xmac(params, vars, 0);
-	else {
+
+	if (CHIP_IS_E3(bp)) {
+		if (vars->mac_type == MAC_TYPE_XMAC)
+			bnx2x_update_pfc_xmac(params, vars, 0);
+	} else {
 		val = REG_RD(bp, MISC_REG_RESET_REG_2);
 		if ((val &
 		     (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port))
-- 
1.7.9.rc2
