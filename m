From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net/cpmac.c: Correct code taking the size of a
 pointer
Date: Sun, 13 Dec 2009 16:35:45 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131635110.27767@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: florian@openwrt.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753627AbZLMPfu@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

sizeof(dev->dev_addr) is the size of a pointer.  On the other hand,
sizeof(pdata->dev_addr) is the size of an array, so use that instead.

A simplified version of the semantic patch that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression *x;
expression f;
type T;
@@

*f(...,(T)x,...)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/cpmac.c                 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 6782223..8d0be26 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1163,7 +1163,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	priv->dev = dev;
 	priv->ring_size = 64;
 	priv->msg_enable = netif_msg_init(debug_level, 0xff);
-	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(dev->dev_addr));
+	memcpy(dev->dev_addr, pdata->dev_addr, sizeof(pdata->dev_addr));
 
 	snprintf(priv->phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
 
