From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net] bnx2x: remove false warning regarding interrupt
 number
Date: Thu, 20 Sep 2012 18:26:41 +0300
Message-ID: <1348154801-6592-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4949 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab2ITPYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2012 11:24:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since version 7.4 the FW configures in the pci config space the max
number of interrupts available to the physical function, instead of
the exact number to use.
This causes a false warning in driver when comparing the number of
configured interrupts to the number about to be used.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 211753e..0875ecf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9831,12 +9831,13 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 	}
 
 #ifdef CONFIG_PCI_MSI
-	/*
-	 * It's expected that number of CAM entries for this functions is equal
-	 * to the number evaluated based on the MSI-X table size. We want a
-	 * harsh warning if these values are different!
+	/* Due to new PF resource allocation by MFW T7.4 and above, it's
+	 * optional that number of CAM entries will not be equal to the value
+	 * advertised in PCI.
+	 * Driver should use the minimal value of both as the actual status
+	 * block count
 	 */
-	WARN_ON(bp->igu_sb_cnt != igu_sb_cnt);
+	bp->igu_sb_cnt = min_t(int, bp->igu_sb_cnt, igu_sb_cnt);
 #endif
 
 	if (igu_sb_cnt == 0)
-- 
1.7.9.GIT
