From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 4/5] netdev: bfin_mac: let boards set vlan masks
Date: Tue, 26 Oct 2010 03:40:26 -0400
Message-ID: <1288078827-17495-4-git-send-email-vapier@gentoo.org>
References: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38827 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718Ab0JZHkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 03:40:22 -0400
In-Reply-To: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c   |    7 +++++++
 drivers/net/bfin_mac.h   |    3 +++
 include/linux/bfin_mac.h |    1 +
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index e712be4..0b9fc51 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -588,6 +588,10 @@ static void setup_system_regs(struct net_device *dev)
 
 	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
 
+	/* Set vlan regs to let 1522 bytes long packets pass through */
+	bfin_write_EMAC_VLAN1(lp->vlan1_mask);
+	bfin_write_EMAC_VLAN2(lp->vlan2_mask);
+
 	/* Initialize the TX DMA channel registers */
 	bfin_write_DMA2_X_COUNT(0);
 	bfin_write_DMA2_X_MODIFY(4);
@@ -1520,6 +1524,9 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 		goto out_err_mii_probe;
 	}
 
+	lp->vlan1_mask = ETH_P_8021Q | mii_bus_data->vlan1_mask;
+	lp->vlan2_mask = ETH_P_8021Q | mii_bus_data->vlan2_mask;
+
 	/* Fill in the fields of the device structure with ethernet values. */
 	ether_setup(ndev);
 
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 4827f6b..c1a0d66 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -75,6 +75,9 @@ struct bfin_mac_local {
 	struct timer_list tx_reclaim_timer;
 	struct net_device *ndev;
 
+	/* Data for EMAC_VLAN1 regs */
+	u16 vlan1_mask, vlan2_mask;
+
 	/* MII and PHY stuffs */
 	int old_link;          /* used by bf537_adjust_link */
 	int old_speed;
diff --git a/include/linux/bfin_mac.h b/include/linux/bfin_mac.h
index 904dec7..a69554e 100644
--- a/include/linux/bfin_mac.h
+++ b/include/linux/bfin_mac.h
@@ -24,6 +24,7 @@ struct bfin_mii_bus_platform_data {
 	const unsigned short *mac_peripherals;
 	int phy_mode;
 	unsigned int phy_mask;
+	unsigned short vlan1_mask, vlan2_mask;
 };
 
 #endif
-- 
1.7.3.2

