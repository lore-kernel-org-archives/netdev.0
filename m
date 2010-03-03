From: Dan Carpenter <error27@gmail.com>
Subject: [patch] davinci_emac: off by one
Date: Wed, 3 Mar 2010 10:07:24 +0300
Message-ID: <20100303070724.GC5086@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chaithrika U S <chaithrika@ti.com>, Sriramakrishnan <srk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Anant Gole <anantgole@ti.com>, kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:38330 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754981Ab0CCHHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 02:07:36 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This off by one error was found by smatch.

drivers/net/davinci_emac.c +2390 emac_dev_open(13) error: buffer overflow 'priv->mac_addr' 6 <= 6

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I don't have the hardware to test this.  If would be cool if someone
would verify that the hardware still works after the patch is applied.

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 1605bc2..eab07cd 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2386,7 +2386,7 @@ static int emac_dev_open(struct net_device *ndev)
 	struct emac_priv *priv = netdev_priv(ndev);
 
 	netif_carrier_off(ndev);
-	for (cnt = 0; cnt <= ETH_ALEN; cnt++)
+	for (cnt = 0; cnt < ETH_ALEN; cnt++)
 		ndev->dev_addr[cnt] = priv->mac_addr[cnt];
 
 	/* Configuration items */
