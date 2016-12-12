From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 1/2] net: ethernet: hisi_femac: Call SET_NETDEV_DEV()
Date: Mon, 12 Dec 2016 20:03:42 +0800
Message-ID: <1481544223-207906-2-git-send-email-lidongpo@hisilicon.com>
References: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <xuejiancheng@hisilicon.com>,
        <benjamin.chenhao@hisilicon.com>, <caizhiyong@hisilicon.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7540 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752136AbcLLMJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 07:09:52 -0500
In-Reply-To: <1481544223-207906-1-git-send-email-lidongpo@hisilicon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hisi_femac driver calls into PHYLIB which now checks for
net_device->dev.parent, so make sure we do set it before calling into
any MDIO/PHYLIB related function.

Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
---
 drivers/net/ethernet/hisilicon/hisi_femac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hisi_femac.c b/drivers/net/ethernet/hisilicon/hisi_femac.c
index 4986306..979852d 100644
--- a/drivers/net/ethernet/hisilicon/hisi_femac.c
+++ b/drivers/net/ethernet/hisilicon/hisi_femac.c
@@ -805,6 +805,7 @@ static int hisi_femac_drv_probe(struct platform_device *pdev)
 		return -ENOMEM;
 
 	platform_set_drvdata(pdev, ndev);
+	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	priv = netdev_priv(ndev);
 	priv->dev = dev;
@@ -882,7 +883,6 @@ static int hisi_femac_drv_probe(struct platform_device *pdev)
 	ndev->netdev_ops = &hisi_femac_netdev_ops;
 	ndev->ethtool_ops = &hisi_femac_ethtools_ops;
 	netif_napi_add(ndev, &priv->napi, hisi_femac_poll, FEMAC_POLL_WEIGHT);
-	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	hisi_femac_port_init(priv);
 
-- 
2.8.2
