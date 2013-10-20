From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 1/9] bnx2x: Fix Maximum CoS estimation for VFs
Date: Sun, 20 Oct 2013 16:51:26 +0200
Message-ID: <1382280694-8428-2-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3402 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059Ab3JTOvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:50 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x VFs do not support Multi-CoS; Current implementation
erroneously sets the VFs maximal number of CoS to be > 1.

This will cause the driver to call alloc_etherdev_mqs() with
a number of queues it cannot possibly support and reflects
in 'odd' driver prints.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 82b658d..60f9e68 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12612,24 +12612,24 @@ static int set_max_cos_est(int chip_id)
 		return BNX2X_MULTI_TX_COS_E1X;
 	case BCM57712:
 	case BCM57712_MF:
-	case BCM57712_VF:
 		return BNX2X_MULTI_TX_COS_E2_E3A0;
 	case BCM57800:
 	case BCM57800_MF:
-	case BCM57800_VF:
 	case BCM57810:
 	case BCM57810_MF:
 	case BCM57840_4_10:
 	case BCM57840_2_20:
 	case BCM57840_O:
 	case BCM57840_MFO:
-	case BCM57810_VF:
 	case BCM57840_MF:
-	case BCM57840_VF:
 	case BCM57811:
 	case BCM57811_MF:
-	case BCM57811_VF:
 		return BNX2X_MULTI_TX_COS_E3B0;
+	case BCM57712_VF:
+	case BCM57800_VF:
+	case BCM57810_VF:
+	case BCM57840_VF:
+	case BCM57811_VF:
 		return 1;
 	default:
 		pr_err("Unknown board_type (%d), aborting\n", chip_id);
-- 
1.8.1.227.g44fe835
