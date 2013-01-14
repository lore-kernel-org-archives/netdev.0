From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 01/10] bnx2x: Clear dirty status when booting
 after UNDI
Date: Mon, 14 Jan 2013 17:11:41 +0200
Message-ID: <1358176310-31504-2-git-send-email-yuvalmin@broadcom.com>
References: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1816 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756679Ab3ANQJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 11:09:55 -0500
In-Reply-To: <1358176310-31504-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self-tests following boot from SAN have failed as the
UNDI driver might leave some NIG interrupt indications.

This patch does the clean-up, clearing those indications
and allowing the test to pass.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a296758..13e5db6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9821,6 +9821,8 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 				prev_undi = true;
 				/* clear the UNDI indication */
 				REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
+				/* clear possible idle check errors */
+				REG_RD(bp, NIG_REG_NIG_INT_STS_CLR_0);
 			}
 		}
 		/* wait until BRB is empty */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index a015965..765e2dc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -2154,6 +2154,8 @@
 /* [R 32] Interrupt register #0 read */
 #define NIG_REG_NIG_INT_STS_0					 0x103b0
 #define NIG_REG_NIG_INT_STS_1					 0x103c0
+/* [RC 32] Interrupt register #0 read clear */
+#define NIG_REG_NIG_INT_STS_CLR_0				 0x103b4
 /* [R 32] Legacy E1 and E1H location for parity error mask register. */
 #define NIG_REG_NIG_PRTY_MASK					 0x103dc
 /* [RW 32] Parity mask register #0 read/write */
-- 
1.8.1.227.g44fe835
