From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 27/41]bnx2x: smp_mb and not just smp_rmb
Date: Thu, 12 Feb 2009 20:37:25 +0200
Message-ID: <1234463845.1863.159.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1654 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758898AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 27/41]bnx2x: smp_mb and not just smp_rmb

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6bd9219..2e95799 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7173,7 +7173,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		cnt = 1000;
-		smp_rmb();
+		smp_mb();
 		while (bnx2x_has_tx_work_unload(fp)) {
 
 			bnx2x_tx_int(fp, 1000);
@@ -7189,7 +7189,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			}
 			cnt--;
 			msleep(1);
-			smp_rmb();
+			smp_mb();
 		}
 	}
 	/* Give HW time to discard old tx messages */
-- 
1.5.4.3




