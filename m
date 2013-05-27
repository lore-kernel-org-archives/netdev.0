From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/6] bnx2x: Zero VFs starting MACs
Date: Mon, 27 May 2013 17:08:26 +0300
Message-ID: <1369663711-32146-2-git-send-email-yuvalmin@broadcom.com>
References: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1744 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932610Ab3E0OIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 10:08:53 -0400
In-Reply-To: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Hypervisor/Supervisor should set the VF's MAC prior to its load;
Using a randomly generated MAC as a default is a bad practice.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7ed9cdf..80982c3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11406,7 +11406,7 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 		if (rc)
 			return rc;
 	} else {
-		random_ether_addr(bp->dev->dev_addr);
+		eth_zero_addr(bp->dev->dev_addr);
 	}
 
 	bnx2x_set_modes_bitmap(bp);
@@ -11865,6 +11865,10 @@ static int bnx2x_validate_addr(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	/* query the bulletin board for mac address configured by the PF */
+	if (IS_VF(bp))
+		bnx2x_sample_bulletin(bp);
+
 	if (!bnx2x_is_valid_ether_addr(bp, dev->dev_addr)) {
 		BNX2X_ERR("Non-valid Ethernet address\n");
 		return -EADDRNOTAVAIL;
-- 
1.8.1.227.g44fe835
