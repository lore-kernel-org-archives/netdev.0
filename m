From: Max Uvarov <muvarov@gmail.com>
Subject: [PATCHv2 2/2] drivers: net: davinci_mdio: print bus frequency
Date: Thu, 10 Aug 2017 10:47:47 +0300
Message-ID: <1502351267-23841-2-git-send-email-muvarov@gmail.com>
References: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        Max Uvarov <muvarov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:38048 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751449AbdHJHrz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 03:47:55 -0400
In-Reply-To: <1502351267-23841-1-git-send-email-muvarov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frequency can be adjusted in DT it make sense to
print current used value on driver init.

Signed-off-by: Max Uvarov <muvarov@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 611e7cc..3c33f45 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -159,8 +159,10 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 
 	/* dump hardware version info */
 	ver = __raw_readl(&data->regs->version);
-	dev_info(data->dev, "davinci mdio revision %d.%d\n",
-		 (ver >> 8) & 0xff, ver & 0xff);
+	dev_info(data->dev,
+		 "davinci mdio revision %d.%d, bus freq %ld\n",
+		 (ver >> 8) & 0xff, ver & 0xff,
+		 data->pdata.bus_freq);
 
 	if (data->skip_scan)
 		goto done;
-- 
2.5.0
