From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 4/9] jme: Rename phyfifo function for easier understand
Date: Mon, 14 Feb 2011 12:27:37 +0800
Message-ID: <1297657662-30289-4-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48725 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145Ab1BNE2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:22 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index d446fdb..490bc0f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -336,13 +336,13 @@ jme_linkstat_from_phy(struct jme_adapter *jme)
 }
 
 static inline void
-jme_set_phyfifoa(struct jme_adapter *jme)
+jme_set_phyfifo_5level(struct jme_adapter *jme)
 {
 	jme_mdio_write(jme->dev, jme->mii_if.phy_id, 27, 0x0004);
 }
 
 static inline void
-jme_set_phyfifob(struct jme_adapter *jme)
+jme_set_phyfifo_8level(struct jme_adapter *jme)
 {
 	jme_mdio_write(jme->dev, jme->mii_if.phy_id, 27, 0x0000);
 }
@@ -457,15 +457,15 @@ jme_check_link(struct net_device *netdev, int testonly)
 				gpreg1 |= GPREG1_HALFMODEPATCH;
 			switch (phylink & PHY_LINK_SPEED_MASK) {
 			case PHY_LINK_SPEED_10M:
-				jme_set_phyfifoa(jme);
+				jme_set_phyfifo_8level(jme);
 				gpreg1 |= GPREG1_RSSPATCH;
 				break;
 			case PHY_LINK_SPEED_100M:
-				jme_set_phyfifob(jme);
+				jme_set_phyfifo_5level(jme);
 				gpreg1 |= GPREG1_RSSPATCH;
 				break;
 			case PHY_LINK_SPEED_1000M:
-				jme_set_phyfifoa(jme);
+				jme_set_phyfifo_8level(jme);
 				break;
 			default:
 				break;
@@ -2979,7 +2979,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->mii_if.mdio_write = jme_mdio_write;
 
 	jme_clear_pm(jme);
-	jme_set_phyfifoa(jme);
+	jme_set_phyfifo_5level(jme);
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &jme->pcirev);
 	if (!jme->fpgaver)
 		jme_phy_init(jme);
-- 
1.7.2.2

