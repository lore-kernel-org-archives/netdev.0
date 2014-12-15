From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: bcmgenet: always select FIXED_PHY
Date: Mon, 15 Dec 2014 09:57:13 -0800
Message-ID: <1418666235-3109-2-git-send-email-f.fainelli@gmail.com>
References: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38224 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaLOR5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:57:39 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so11679228pab.33
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 09:57:38 -0800 (PST)
In-Reply-To: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to do the following:

select FIXED_PHY if BCMGENET=y, as this implies that we will not be able
to build and/or run the driver correctly when built as a module, which
is no longer an issue since commit 37e9a6904520 ("net: phy: export
fixed_phy_register()")

Fixes: b0ba512e225d ("net: bcmgenet: enable driver to work without device tree"
Fixes: bdaa53bde55f ("net: bcmgenet: hook into the build system")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 888247ad9068..f4789a059d54 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -64,7 +64,7 @@ config BCMGENET
 	tristate "Broadcom GENET internal MAC support"
 	select MII
 	select PHYLIB
-	select FIXED_PHY if BCMGENET=y
+	select FIXED_PHY
 	select BCM7XXX_PHY
 	help
 	  This driver supports the built-in Ethernet MACs found in the
-- 
2.1.0
