From: Harvey Hunt <harvey.hunt@imgtec.com>
Subject: [PATCH net] drivers: net: Don't print unpopulated net_device name
Date: Tue, 10 May 2016 17:43:21 +0100
Message-ID: <1462898601-5429-1-git-send-email-harvey.hunt@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Harvey Hunt <harvey.hunt@imgtec.com>,
	Robert Jarzmik <robert.jarzmik@free.fr>,
	Barry Song <Baohua.Song@csr.com>,
	Marcel Ziswiler <marcel@ziswiler.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ethernet devices, net_device.name will be eth%d before
register_netdev() is called. Don't print the net_device name until
the format string is replaced.

Cc: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Barry Song <Baohua.Song@csr.com>
Cc: Marcel Ziswiler <marcel@ziswiler.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Harvey Hunt <harvey.hunt@imgtec.com>
---
I've tested this patch on a board that has a DM9000, but haven't 
tested the other two network devices.

 drivers/net/ethernet/davicom/dm9000.c   | 3 +--
 drivers/net/ethernet/micrel/ks8695net.c | 3 +--
 drivers/net/ethernet/netx-eth.c         | 3 +--
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 48d9194..89dcaa1 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1686,8 +1686,7 @@ dm9000_probe(struct platform_device *pdev)
 	}
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
-		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
+		dev_warn(db->dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
 
 		eth_hw_addr_random(ndev);
 		mac_src = "random";
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index a8522d8..2e2ea61 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1456,8 +1456,7 @@ ks8695_probe(struct platform_device *pdev)
 	ndev->dev_addr[5] = maclow & 0xFF;
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		dev_warn(ksp->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
+		dev_warn(ksp->dev, "Invalid ethernet MAC address. Please set using ifconfig\n");
 
 	/* In order to be efficient memory-wise, we allocate both
 	 * rings in one go.
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 9fbc302..c2e2151 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -358,8 +358,7 @@ static int netx_eth_enable(struct net_device *ndev)
 	xc_start(priv->xc);
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		printk("%s: Invalid ethernet MAC address.  Please "
-		       "set using ifconfig\n", ndev->name);
+		printk("Invalid ethernet MAC address. Please set using ifconfig\n");
 
 	for (i=2; i<=18; i++)
 		pfifo_push(EMPTY_PTR_FIFO(priv->id),
-- 
2.8.0
