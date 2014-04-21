From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] stmmac: remove stmmac_config
Date: Mon, 21 Apr 2014 09:09:22 -0700
Message-ID: <1398096563-8786-5-git-send-email-f.fainelli@gmail.com>
References: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, peppe.cavallaro@st.com,
	jcmvbkbc@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:51595 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752490AbaDUQJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:09:43 -0400
Received: by mail-qg0-f47.google.com with SMTP id e89so402412qgf.20
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:09:43 -0700 (PDT)
In-Reply-To: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stmmac_config() denies changing the base address and interrupt
parameters, and ignores any other settings from the ifmap parameters,
thus making stmmac_config() useless, remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index d940034acdd4..93cf4f63f426 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2214,27 +2214,6 @@ static void stmmac_tx_timeout(struct net_device *dev)
 	stmmac_tx_err(priv);
 }
 
-/* Configuration changes (passed on by ifconfig) */
-static int stmmac_config(struct net_device *dev, struct ifmap *map)
-{
-	if (dev->flags & IFF_UP)	/* can't act on a running interface */
-		return -EBUSY;
-
-	/* Don't allow changing the I/O address */
-	if (map->base_addr != dev->base_addr) {
-		pr_warn("%s: can't change I/O address\n", dev->name);
-		return -EOPNOTSUPP;
-	}
-
-	/* Don't allow changing the IRQ */
-	if (map->irq != dev->irq) {
-		pr_warn("%s: not change IRQ number %d\n", dev->name, dev->irq);
-		return -EOPNOTSUPP;
-	}
-
-	return 0;
-}
-
 /**
  *  stmmac_set_rx_mode - entry point for multicast addressing
  *  @dev : pointer to the device structure
@@ -2600,7 +2579,6 @@ static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_set_rx_mode = stmmac_set_rx_mode,
 	.ndo_tx_timeout = stmmac_tx_timeout,
 	.ndo_do_ioctl = stmmac_ioctl,
-	.ndo_set_config = stmmac_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = stmmac_poll_controller,
 #endif
-- 
1.9.1
