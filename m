From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 07/13] bnx2x: Ext. config accessed only on
 non-E1x.
Date: Sun, 2 Dec 2012 16:05:51 +0200
Message-ID: <1354457157-4730-8-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2488 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753156Ab2LBOFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:14 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 89b3d10..571508d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10484,8 +10484,9 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 		if (BNX2X_MF_EXT_PROTOCOL_FCOE(bp) && !CHIP_IS_E1x(bp))
 			bnx2x_get_ext_wwn_info(bp, func);
 
-	} else if (IS_MF_FCOE_SD(bp))
+	} else if (IS_MF_FCOE_SD(bp) && !CHIP_IS_E1x(bp)) {
 		bnx2x_get_ext_wwn_info(bp, func);
+	}
 
 	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n", bp->cnic_eth_dev.max_fcoe_conn);
 
-- 
1.7.1
