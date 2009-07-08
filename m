From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 5/8 net-next-2.6] cxgb3: fix phy power down
Date: Tue, 07 Jul 2009 22:48:53 -0700
Message-ID: <20090708054853.11344.89582.stgit@speedy5>
References: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6812 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758371AbZGHFsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:48:55 -0400
In-Reply-To: <20090708054832.11344.82449.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

2 phys are were not getting the Global Tx disable bit set
when powered down, leading to an inconsistent link state
on peer.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/ael1002.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)


diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 99e3e0f..66e47f7 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -224,12 +224,6 @@ static int ael1006_reset(struct cphy *phy, int wait)
 	return t3_phy_reset(phy, MDIO_MMD_PMAPMD, wait);
 }
 
-static int ael1006_power_down(struct cphy *phy, int enable)
-{
-	return mdio_set_flag(&phy->mdio, phy->mdio.prtad, MDIO_MMD_PMAPMD,
-			     MDIO_CTRL1, MDIO_CTRL1_LPOWER, enable);
-}
-
 static struct cphy_ops ael1006_ops = {
 	.reset = ael1006_reset,
 	.intr_enable = t3_phy_lasi_intr_enable,
@@ -237,7 +231,7 @@ static struct cphy_ops ael1006_ops = {
 	.intr_clear = t3_phy_lasi_intr_clear,
 	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = get_link_status_r,
-	.power_down = ael1006_power_down,
+	.power_down = ael1002_power_down,
 	.mmds = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 
@@ -1888,7 +1882,7 @@ static struct cphy_ops qt2045_ops = {
 	.intr_clear = t3_phy_lasi_intr_clear,
 	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = get_link_status_x,
-	.power_down = ael1006_power_down,
+	.power_down = ael1002_power_down,
 	.mmds = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 

