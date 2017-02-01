From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH] net: stmmac: add separate warning for PTP not being supported
 by HW
Date: Wed, 1 Feb 2017 22:02:02 +0100
Message-ID: <0983485b-418d-5c9b-e94b-8f4edc9f13cf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-amlogic@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34974 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752047AbdBAVFY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 16:05:24 -0500
Received: by mail-wj0-f193.google.com with SMTP id i7so14305079wjf.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 13:05:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chips like Amlogic S905GXBB are supported by this driver but don't
have support for PTP. Add a separate warning for missing HW support
to differentiate it from other actual failures.

Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 26a2185f..bd83bf9e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1726,8 +1726,10 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 
 	if (init_ptp) {
 		ret = stmmac_init_ptp(priv);
-		if (ret)
-			netdev_warn(priv->dev, "fail to init PTP.\n");
+		if (ret == -EOPNOTSUPP)
+			netdev_warn(priv->dev, "PTP not supported by HW\n");
+		else if (ret)
+			netdev_warn(priv->dev, "PTP init failed\n");
 	}
 
 #ifdef CONFIG_DEBUG_FS
-- 
2.11.0
