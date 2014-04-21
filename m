From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: sxgbe: remove sxgbe_config
Date: Mon, 21 Apr 2014 09:09:21 -0700
Message-ID: <1398096563-8786-4-git-send-email-f.fainelli@gmail.com>
References: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, peppe.cavallaro@st.com,
	jcmvbkbc@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:41001 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaDUQJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:09:41 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so4082630qgd.41
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:09:40 -0700 (PDT)
In-Reply-To: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sxgbe_config() denies changing the base address and interrupt, and
ignores all other 'struct ifmap' members, which means that it is useless
as is, so let's remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c | 35 -------------------------
 1 file changed, 35 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index 5091692ad659..137f366ec7e4 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1909,40 +1909,6 @@ static void sxgbe_set_rx_mode(struct net_device *dev)
 		   readl(ioaddr + SXGBE_HASH_LOW));
 }
 
-/**
- * sxgbe_config - entry point for changing configuration mode passed on by
- * ifconfig
- * @dev : pointer to the device structure
- * @map : pointer to the device mapping structure
- * Description:
- * This function is a driver entry point which gets called by the kernel
- * whenever some device configuration is changed.
- * Return value:
- * This function returns 0 if success and appropriate error otherwise.
- */
-static int sxgbe_config(struct net_device *dev, struct ifmap *map)
-{
-	struct sxgbe_priv_data *priv = netdev_priv(dev);
-
-	/* Can't act on a running interface */
-	if (dev->flags & IFF_UP)
-		return -EBUSY;
-
-	/* Don't allow changing the I/O address */
-	if (map->base_addr != (unsigned long)priv->ioaddr) {
-		netdev_warn(dev, "can't change I/O address\n");
-		return -EOPNOTSUPP;
-	}
-
-	/* Don't allow changing the IRQ */
-	if (map->irq != priv->irq) {
-		netdev_warn(dev, "not change IRQ number %d\n", priv->irq);
-		return -EOPNOTSUPP;
-	}
-
-	return 0;
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /**
  * sxgbe_poll_controller - entry point for polling receive by device
@@ -2004,7 +1970,6 @@ static const struct net_device_ops sxgbe_netdev_ops = {
 	.ndo_set_rx_mode	= sxgbe_set_rx_mode,
 	.ndo_tx_timeout		= sxgbe_tx_timeout,
 	.ndo_do_ioctl		= sxgbe_ioctl,
-	.ndo_set_config		= sxgbe_config,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= sxgbe_poll_controller,
 #endif
-- 
1.9.1
