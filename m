From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] net: dsa: bcm_sf2: always select FIXED_PHY
Date: Mon, 15 Dec 2014 09:57:15 -0800
Message-ID: <1418666235-3109-4-git-send-email-f.fainelli@gmail.com>
References: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:61182 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbaLOR5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:57:40 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so12214525pad.24
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 09:57:40 -0800 (PST)
In-Reply-To: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to do the following:

select FIXED_PHY if NET_DSA_BCM_SF2=y, as this implies that we will not be
able to build and/or run the driver correctly when built as a module,
which is no longer an issue since commit 37e9a6904520 ("net: phy: export
fixed_phy_register()").

Fixes: 246d7f773c13ca ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 7cf8f4ac281f..48e62a34f7f2 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -59,7 +59,7 @@ config NET_DSA_BCM_SF2
 	depends on HAS_IOMEM
 	select NET_DSA
 	select NET_DSA_TAG_BRCM
-	select FIXED_PHY if NET_DSA_BCM_SF2=y
+	select FIXED_PHY
 	select BCM7XXX_PHY
 	select MDIO_BCM_UNIMAC
 	---help---
-- 
2.1.0
