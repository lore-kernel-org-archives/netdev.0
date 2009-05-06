From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 2/3] bnx2x: assure we release PHY lock only when is taken
Date: Wed, 6 May 2009 11:22:07 +0200
Message-ID: <20090506112207.4d3ae9c4@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35055 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753184AbZEFJ2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 05:28:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ff2d9f6..5bd42db 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2585,10 +2585,11 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	REG_WR(bp, hc_addr, asserted);
 
 	/* now set back the mask */
-	if (asserted & ATTN_NIG_FOR_FUNC) {
-		REG_WR(bp, nig_int_mask_addr, nig_mask);
-		bnx2x_release_phy_lock(bp);
-	}
+	if (asserted & ATTN_HARD_WIRED_MASK)
+		if (asserted & ATTN_NIG_FOR_FUNC) {
+			REG_WR(bp, nig_int_mask_addr, nig_mask);
+			bnx2x_release_phy_lock(bp);
+		}
 }
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
-- 
1.5.5.6

