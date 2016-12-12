From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 2/2] net: ethernet: hip04: Call SET_NETDEV_DEV()
Date: Mon, 12 Dec 2016 20:03:43 +0800
Message-ID: <1481544223-207906-3-git-send-email-lidongpo@hisilicon.com>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <xuejiancheng@hisilicon.com>,
        <benjamin.chenhao@hisilicon.com>, <caizhiyong@hisilicon.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hip04 driver calls into PHYLIB which now checks for
net_device->dev.parent, so make sure we do set it before calling into
any MDIO/PHYLIB related function.

Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hip04_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 854befd..97b1847 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -828,6 +828,7 @@ static int hip04_mac_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
 	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	priv->base = devm_ioremap_resource(d, res);
@@ -903,7 +904,6 @@ static int hip04_mac_probe(struct platform_device *pdev)
 	ndev->priv_flags |= IFF_UNICAST_FLT;
 	ndev->irq = irq;
 	netif_napi_add(ndev, &priv->napi, hip04_rx_poll, NAPI_POLL_WEIGHT);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	hip04_reset_ppe(priv);
 	if (priv->phy_mode == PHY_INTERFACE_MODE_MII)
-- 
2.8.2
