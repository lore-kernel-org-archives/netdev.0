From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] fec: Use gpio_set_value_cansleep()
Date: Wed, 28 Oct 2015 10:20:30 -0200
Message-ID: <1446034830-13640-1-git-send-email-festevam@gmail.com>
Cc: netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:35717 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868AbbJ1MUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 08:20:41 -0400
Received: by vkfw189 with SMTP id w189so3348531vkf.2
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 05:20:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

We are in a context where we can sleep, and the FEC PHY reset gpio
may be on an I2C expander. Use the cansleep() variant when
setting the GPIO value.

Based on a patch from Russell King for pci-mvebu.c.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 501e143..b2a3220 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3261,7 +3261,7 @@ static void fec_reset_phy(struct platform_device *pdev)
 		return;
 	}
 	msleep(msec);
-	gpio_set_value(phy_reset, 1);
+	gpio_set_value_cansleep(phy_reset, 1);
 }
 #else /* CONFIG_OF */
 static void fec_reset_phy(struct platform_device *pdev)
-- 
1.9.1
