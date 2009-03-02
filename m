From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 01/18] bnx2x: Remove redundant smb_mb on unload
Date: Mon, 02 Mar 2009 19:59:17 +0200
Message-ID: <1236016757.7723.72.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Ben Hutchings" <bhutchings@solarflare.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754922AbZCBSAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 01/18] bnx2x: Remove redundant smb_mb on unload

As noted by Ben Hutchings <bhutchings@solarflare.com>, these smb_mb are not
needed

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9427175..5954bed 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7210,7 +7210,6 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		cnt = 1000;
-		smp_mb();
 		while (bnx2x_has_tx_work_unload(fp)) {
 
 			bnx2x_tx_int(fp, 1000);
@@ -7226,7 +7225,6 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			}
 			cnt--;
 			msleep(1);
-			smp_mb();
 		}
 	}
 	/* Give HW time to discard old tx messages */
-- 
1.5.4.3




