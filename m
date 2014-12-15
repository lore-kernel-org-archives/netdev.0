From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: systemport: always select FIXED_PHY
Date: Mon, 15 Dec 2014 09:57:14 -0800
Message-ID: <1418666235-3109-3-git-send-email-f.fainelli@gmail.com>
References: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36455 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaLOR5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 12:57:40 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so12158788pde.29
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 09:57:39 -0800 (PST)
In-Reply-To: <1418666235-3109-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to do the following:

select FIXED_PHY if SYSTEMPORT=y, as this implies that we will not be able
to build and/or run the driver correctly when built as a module, which
is no longer an issue since commit 37e9a6904520 ("net: phy: export
fixed_phy_register()")

Fixes: a3862db2d3c4 ("net: systemport: hook SYSTEMPORT driver in the build")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index f4789a059d54..41a3c9804427 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -155,7 +155,7 @@ config SYSTEMPORT
 	depends on OF
 	select MII
 	select PHYLIB
-	select FIXED_PHY if SYSTEMPORT=y
+	select FIXED_PHY
 	help
 	  This driver supports the built-in Ethernet MACs found in the
 	  Broadcom BCM7xxx Set Top Box family chipset using an internal
-- 
2.1.0
