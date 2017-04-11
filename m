From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 05/10] ftgmac100: Rename ftgmac100_set_mac to ftgmac100_write_mac_addr
Date: Tue, 11 Apr 2017 11:04:31 +1000
Message-ID: <20170411010436.23290-6-benh@kernel.crashing.org>
References: <20170411010436.23290-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51427 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752350AbdDKBF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 21:05:57 -0400
In-Reply-To: <20170411010436.23290-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid confusion with the ndo callback and generally be
clearer about the purpose of that function

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 257243a..c2053e5 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -173,7 +173,7 @@ static int ftgmac100_reset_and_config_mac(struct ftgmac100 *priv)
 	return ftgmac100_reset_mac(priv, maccr);
 }
 
-static void ftgmac100_set_mac(struct ftgmac100 *priv, const unsigned char *mac)
+static void ftgmac100_write_mac_addr(struct ftgmac100 *priv, const u8 *mac)
 {
 	unsigned int maddr = mac[0] << 8 | mac[1];
 	unsigned int laddr = mac[2] << 24 | mac[3] << 16 | mac[4] << 8 | mac[5];
@@ -226,7 +226,7 @@ static int ftgmac100_set_mac_addr(struct net_device *dev, void *p)
 		return ret;
 
 	eth_commit_mac_addr_change(dev, p);
-	ftgmac100_set_mac(netdev_priv(dev), dev->dev_addr);
+	ftgmac100_write_mac_addr(netdev_priv(dev), dev->dev_addr);
 
 	return 0;
 }
@@ -245,7 +245,7 @@ static void ftgmac100_init_hw(struct ftgmac100 *priv)
 
 	iowrite32(FTGMAC100_APTC_RXPOLL_CNT(1), priv->base + FTGMAC100_OFFSET_APTC);
 
-	ftgmac100_set_mac(priv, priv->netdev->dev_addr);
+	ftgmac100_write_mac_addr(priv, priv->netdev->dev_addr);
 }
 
 static void ftgmac100_start_hw(struct ftgmac100 *priv)
-- 
2.9.3
