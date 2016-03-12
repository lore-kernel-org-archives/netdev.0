From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: kill useless initializers
Date: Sun, 13 Mar 2016 01:29:45 +0300
Message-ID: <2737382.tXjN0OZRaC@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of the local variable intializers in the driver turned out to be
pointless,  kill 'em.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the DaveM's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -447,8 +447,8 @@ static bool sh_eth_is_rz_fast_ether(stru
 
 static void sh_eth_select_mii(struct net_device *ndev)
 {
-	u32 value = 0x0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u32 value;
 
 	switch (mdp->phy_interface) {
 	case PHY_INTERFACE_MODE_GMII:
@@ -1231,8 +1231,8 @@ ring_free:
 
 static int sh_eth_dev_init(struct net_device *ndev, bool start)
 {
-	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
 
 	/* Soft Reset */
 	ret = sh_eth_reset(ndev);
@@ -1355,7 +1355,7 @@ static int sh_eth_txfree(struct net_devi
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_txdesc *txdesc;
 	int free_num = 0;
-	int entry = 0;
+	int entry;
 
 	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
 		entry = mdp->dirty_tx % mdp->num_tx_ring;
@@ -1396,10 +1396,10 @@ static int sh_eth_rx(struct net_device *
 	int boguscnt = (mdp->dirty_rx + mdp->num_rx_ring) - mdp->cur_rx;
 	int limit;
 	struct sk_buff *skb;
-	u16 pkt_len = 0;
 	u32 desc_status;
 	int skbuff_size = mdp->rx_buf_sz + SH_ETH_RX_ALIGN + 32 - 1;
 	dma_addr_t dma_addr;
+	u16 pkt_len;
 	u32 buf_len;
 
 	boguscnt = min(boguscnt, *quota);
@@ -1778,7 +1778,7 @@ static int sh_eth_phy_init(struct net_de
 {
 	struct device_node *np = ndev->dev.parent->of_node;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
-	struct phy_device *phydev = NULL;
+	struct phy_device *phydev;
 
 	mdp->link = 0;
 	mdp->speed = 0;
@@ -2232,8 +2232,8 @@ static const struct ethtool_ops sh_eth_e
 /* network device open function */
 static int sh_eth_open(struct net_device *ndev)
 {
-	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int ret;
 
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
@@ -2988,12 +2988,12 @@ static inline struct sh_eth_plat_data *s
 
 static int sh_eth_drv_probe(struct platform_device *pdev)
 {
-	int ret, devno = 0;
 	struct resource *res;
-	struct net_device *ndev = NULL;
-	struct sh_eth_private *mdp = NULL;
 	struct sh_eth_plat_data *pd = dev_get_platdata(&pdev->dev);
 	const struct platform_device_id *id = platform_get_device_id(pdev);
+	struct sh_eth_private *mdp;
+	struct net_device *ndev;
+	int ret, devno;
 
 	/* get base addr */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
