From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] mdio: unused ethtool functions
Date: Thu, 26 Dec 2013 10:12:41 -0800
Message-ID: <20131226101241.5f38e392@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:52348 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab3LZSMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:12:46 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so8269169pdi.38
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 10:12:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use it or lose it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/mdio.c   |   28 ----------------------------
 include/linux/mdio.h |    3 ---
 2 files changed, 31 deletions(-)

--- a/drivers/net/mdio.c	2013-12-24 15:37:35.779661759 -0800
+++ b/drivers/net/mdio.c	2013-12-24 15:38:26.054970175 -0800
@@ -342,34 +342,6 @@ void mdio45_ethtool_gset_npage(const str
 EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
 
 /**
- * mdio45_ethtool_spauseparam_an - set auto-negotiated pause parameters
- * @mdio: MDIO interface
- * @ecmd: Ethtool request structure
- *
- * This function assumes that the PHY has an auto-negotiation MMD.  It
- * will enable and disable advertising of flow control as appropriate.
- */
-void mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
-				   const struct ethtool_pauseparam *ecmd)
-{
-	int adv, old_adv;
-
-	WARN_ON(!(mdio->mmds & MDIO_DEVS_AN));
-
-	old_adv = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
-				  MDIO_AN_ADVERTISE);
-	adv = ((old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) |
-	       mii_advertise_flowctrl((ecmd->rx_pause ? FLOW_CTRL_RX : 0) |
-				      (ecmd->tx_pause ? FLOW_CTRL_TX : 0)));
-	if (adv != old_adv) {
-		mdio->mdio_write(mdio->dev, mdio->prtad, MDIO_MMD_AN,
-				 MDIO_AN_ADVERTISE, adv);
-		mdio45_nway_restart(mdio);
-	}
-}
-EXPORT_SYMBOL(mdio45_ethtool_spauseparam_an);
-
-/**
  * mdio_mii_ioctl - MII ioctl interface for MDIO (clause 22 or 45) PHYs
  * @mdio: MDIO interface
  * @mii_data: MII ioctl data structure
--- a/include/linux/mdio.h	2013-12-24 15:37:35.779661759 -0800
+++ b/include/linux/mdio.h	2013-12-24 15:38:26.054970175 -0800
@@ -70,9 +70,6 @@ extern int mdio45_nway_restart(const str
 extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 				      struct ethtool_cmd *ecmd,
 				      u32 npage_adv, u32 npage_lpa);
-extern void
-mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
-			      const struct ethtool_pauseparam *ecmd);
 
 /**
  * mdio45_ethtool_gset - get settings for ETHTOOL_GSET
