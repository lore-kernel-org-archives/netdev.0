From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH 1/2] net: ethernet: davinci_emac: Fix Unbalanced pm_runtime_enable
Date: Wed, 20 Apr 2016 10:56:13 +0200
Message-ID: <1461142573-4276-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
	Brian Hutchinson <b.hutchman@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to avoid an Unbalanced pm_runtime_enable in the DaVinci
emac driver when the device is removed and re-probed, and a
pm_runtime_disable() call in davinci_emac_remove().

Actually, using unbind/bind on a TI DM8168 SoC gives :
$ echo 4a120000.ethernet > /sys/bus/platform/drivers/davinci_emac/unbind
net eth1: DaVinci EMAC: davinci_emac_remove()
$ echo 4a120000.ethernet > /sys/bus/platform/drivers/davinci_emac/bind
davinci_emac 4a120000.ethernet: Unbalanced pm_runtime_enable

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Fixes: 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support")
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 5d9abed..e9fe3fb 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -2101,6 +2101,7 @@ static int davinci_emac_remove(struct platform_device *pdev)
 	cpdma_ctlr_destroy(priv->dma);
 
 	unregister_netdev(ndev);
+	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
 
 	return 0;
-- 
1.9.1
