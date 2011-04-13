From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: review Wol and enable the Unicast support
Date: Wed, 13 Apr 2011 09:27:15 +0200
Message-ID: <1302679635-7035-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:47131 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757046Ab1DMH1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 03:27:33 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id ED23ADD
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 07:27:22 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AB9531806
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 07:27:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/dwmac1000_core.c |    5 +++--
 drivers/net/stmmac/stmmac_ethtool.c |    4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 6ae4c3f..f20455c 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -178,10 +178,11 @@ static void dwmac1000_pmt(void __iomem *ioaddr, unsigned long mode)
 {
 	unsigned int pmt = 0;
 
-	if (mode == WAKE_MAGIC) {
+	if (mode & WAKE_MAGIC) {
 		CHIP_DBG(KERN_DEBUG "GMAC: WOL Magic frame\n");
 		pmt |= power_down | magic_pkt_en;
-	} else if (mode == WAKE_UCAST) {
+	}
+	if (mode & WAKE_UCAST) {
 		CHIP_DBG(KERN_DEBUG "GMAC: WOL on global unicast\n");
 		pmt |= global_unicast;
 	}
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 156a805..0e61ac8 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -308,7 +308,7 @@ static void stmmac_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	spin_lock_irq(&priv->lock);
 	if (device_can_wakeup(priv->device)) {
-		wol->supported = WAKE_MAGIC;
+		wol->supported = WAKE_MAGIC | WAKE_UCAST;
 		wol->wolopts = priv->wolopts;
 	}
 	spin_unlock_irq(&priv->lock);
@@ -317,7 +317,7 @@ static void stmmac_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 static int stmmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	u32 support = WAKE_MAGIC;
+	u32 support = WAKE_MAGIC | WAKE_UCAST;
 
 	if (!device_can_wakeup(priv->device))
 		return -EINVAL;
-- 
1.7.4.2

