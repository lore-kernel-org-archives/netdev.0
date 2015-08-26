From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH, net-next] r8169:Actually from r810x_pll_power_up
Date: Wed, 26 Aug 2015 16:08:25 +0300
Message-ID: <1440594505-2908-1-git-send-email-corcodel.marian@gmail.com>
Cc: Corcodel Marian <corcodel.marian@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36096 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHZNIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 09:08:37 -0400
Received: by wicja10 with SMTP id ja10so44139334wic.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 06:08:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually from r810x_pll_power_up function i removed function
  r810x_phy_power_up because is two situation.One run from  rtl8169_phy_reset
 wich already power on interface after reset MII_BMCR  and two i placed
 supplementary on __rtl8169_resume.

Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 91cf3a6..2d712a4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4699,7 +4699,6 @@ static void r810x_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	r810x_phy_power_up(tp);
 
 	switch (tp->mac_version) {
 	case RTL_GIGA_MAC_VER_07:
@@ -7862,7 +7861,7 @@ static void __rtl8169_resume(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 
 	netif_device_attach(dev);
-
+	r810x_phy_power_up(tp);	
 	rtl_pll_power_up(tp);
 
 	rtl_lock_work(tp);
-- 
2.1.4
