From: Kosta Zertsekel <konszert@marvell.com>
Subject: [PATCH 2/2] Fix phy_attach - forward dev_flags for phy_attach
Date: Thu, 10 Jan 2013 14:00:34 +0200
Message-ID: <1357819234-27752-3-git-send-email-konszert@marvell.com>
References: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Cc: zertsekel@gmail.com, andrew@lunn.ch, benavi@marvell.com,
	linux-arm-kernel@lists.infradead.org, alior@marvell.com,
	Kosta Zertsekel <konszert@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:40093 "EHLO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750984Ab3AJMJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 07:09:47 -0500
In-Reply-To: <1357819234-27752-1-git-send-email-konszert@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change-Id: Ie3191f95c36eada6d0c673460de5393641128182
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 2 +-
 net/dsa/slave.c                           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 10d678d..63baa3b 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1391,7 +1391,7 @@ static void phy_init(struct pxa168_eth_private *pep, int speed, int duplex)
 	struct phy_device *phy = pep->phy;
 	ethernet_phy_reset(pep);
 
-	phy_attach(pep->dev, dev_name(&phy->dev), 0, PHY_INTERFACE_MODE_MII);
+	phy_attach(pep->dev, dev_name(&phy->dev), phy->dev_flags, PHY_INTERFACE_MODE_MII);
 
 	if (speed == 0) {
 		phy->autoneg = AUTONEG_ENABLE;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e32083d..bf09902 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -391,7 +391,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	if (p->phy != NULL) {
 		phy_attach(slave_dev, dev_name(&p->phy->dev),
-			   0, PHY_INTERFACE_MODE_GMII);
+			   phy->dev_flags, PHY_INTERFACE_MODE_GMII);
 
 		p->phy->autoneg = AUTONEG_ENABLE;
 		p->phy->speed = 0;
-- 
1.8.1
