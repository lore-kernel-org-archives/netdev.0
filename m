From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] r6040: check for absent PHY
Date: Tue, 5 May 2009 08:30:01 +0200
Message-ID: <200905050830.01683.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:8132 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbZEEGaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 02:30:06 -0400
Received: by ey-out-2122.google.com with SMTP id 9so1139572eyd.37
        for <netdev@vger.kernel.org>; Mon, 04 May 2009 23:30:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices have two R6040 MACs but the second one
is not wired to any PHY, therefore the interface is
just unusable. Warn the user about that and prevent
device from registering.

Tested-by: bifferos <bifferos@yahoo.co.uk>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6f97b47..b75b047 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -742,6 +742,14 @@ static int r6040_up(struct net_device *dev)
 	struct r6040_private *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->base;
 	int ret;
+	u16 val;
+	
+	/* Check presence of a second PHY */
+	val = r6040_phy_read(ioaddr, lp->phy_addr, 2);
+	if (val == 0xFFFF) {
+		printk(KERN_ERR DRV_NAME " no second PHY attached\n");
+		return -EIO;
+	}
 
 	/* Initialise and alloc RX/TX buffers */
 	r6040_init_txbufs(dev);
