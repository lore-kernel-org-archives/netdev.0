From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v3 1/6] fsl/fman: remove of_node
Date: Mon, 16 Oct 2017 21:36:05 +0300
Message-ID: <1508178970-28945-2-git-send-email-madalin.bucur@nxp.com>
References: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <junote@outlook.com>,
        <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508178970-28945-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The FMan MAC driver allocates a platform device for the Ethernet
driver to probe on. Setting pdev->dev.of_node with the MAC node
triggers the MAC driver probing of the new platform device. While
this fails quickly and does not affect the functionality of the
drivers, it is incorrect and must be removed. This was added to
address a report that DSA code using of_find_net_device_by_node()
is unable to use the DPAA interfaces. Error message seen before
this fix:

fsl_mac dpaa-ethernet.0: __devm_request_mem_region(mac) failed
fsl_mac: probe of dpaa-ethernet.0 failed with error -16

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 387eb4a..9a265f8 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -623,7 +623,6 @@ static struct platform_device *dpaa_eth_add_device(int fman_id,
 		goto no_mem;
 	}
 
-	pdev->dev.of_node = node;
 	pdev->dev.parent = priv->dev;
 	set_dma_ops(&pdev->dev, get_dma_ops(priv->dev));
 
-- 
2.1.0
