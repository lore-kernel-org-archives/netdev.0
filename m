From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net v2 4/9] bnx2x: Fix Coalescing configuration
Date: Sun, 20 Oct 2013 16:51:29 +0200
Message-ID: <1382280694-8428-5-git-send-email-yuvalmin@broadcom.com>
References: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3402 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab3JTOvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 10:51:55 -0400
In-Reply-To: <1382280694-8428-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

bnx2x drivers configure coalescing incorrectly (e.g., as a result of a call
to 'ethtool -c'). Although this is almost invisible to the user (due to NAPI)
designated tests will show the configuration is incorrect.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index d21742c..986edbf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1621,7 +1621,7 @@ struct bnx2x {
 	u16			rx_ticks_int;
 	u16			rx_ticks;
 /* Maximal coalescing timeout in us */
-#define BNX2X_MAX_COALESCE_TOUT		(0xf0*12)
+#define BNX2X_MAX_COALESCE_TOUT		(0xff*BNX2X_BTR)
 
 	u32			lin_cnt;
 
-- 
1.8.1.227.g44fe835
