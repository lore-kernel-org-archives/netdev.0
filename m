From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 7/24] bnx2x: do not call link update without HW
 notification
Date: Tue, 14 Jun 2011 14:33:19 +0300
Message-ID: <201106141433.19525.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2495 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756260Ab1FNLeV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:34:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index e6439a3..0e8d302 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2885,9 +2885,15 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 			/* save nig interrupt mask */
 			nig_mask = REG_RD(bp, nig_int_mask_addr);
-			REG_WR(bp, nig_int_mask_addr, 0);
 
-			bnx2x_link_attn(bp);
+			/* If nig_mask is not set, no need to call the update
+			 * function.
+			 */
+			if (nig_mask) {
+				REG_WR(bp, nig_int_mask_addr, 0);
+
+				bnx2x_link_attn(bp);
+			}
 
 			/* handle unicore attn? */
 		}
-- 
1.7.2.2


