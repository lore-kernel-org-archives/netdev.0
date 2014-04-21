From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: cpmac: remove cpmac_config
Date: Mon, 21 Apr 2014 09:09:20 -0700
Message-ID: <1398096563-8786-3-git-send-email-f.fainelli@gmail.com>
References: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, bh74.an@samsung.com, ks.giri@samsung.com,
	siva.kallam@samsung.com, peppe.cavallaro@st.com,
	jcmvbkbc@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:47971 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaDUQPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 12:15:47 -0400
Received: by mail-qc0-f175.google.com with SMTP id e16so4174803qcx.20
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 09:15:47 -0700 (PDT)
In-Reply-To: <1398096563-8786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpmac_config() refuses changing the base address parameter, and ignores
all other parameters, which means that it is pretty useless as it is, so
let's remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ti/cpmac.c | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 73f74f369437..7399a52f7c26 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -313,19 +313,6 @@ static int mii_irqs[PHY_MAX_ADDR] = { PHY_POLL, };
 
 static struct mii_bus *cpmac_mii;
 
-static int cpmac_config(struct net_device *dev, struct ifmap *map)
-{
-	if (dev->flags & IFF_UP)
-		return -EBUSY;
-
-	/* Don't allow changing the I/O address */
-	if (map->base_addr != dev->base_addr)
-		return -EOPNOTSUPP;
-
-	/* ignore other fields */
-	return 0;
-}
-
 static void cpmac_set_multicast_list(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
@@ -1100,7 +1087,6 @@ static const struct net_device_ops cpmac_netdev_ops = {
 	.ndo_tx_timeout		= cpmac_tx_timeout,
 	.ndo_set_rx_mode	= cpmac_set_multicast_list,
 	.ndo_do_ioctl		= cpmac_ioctl,
-	.ndo_set_config		= cpmac_config,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
-- 
1.9.1
