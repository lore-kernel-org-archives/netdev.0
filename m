From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH 2/3] net: macb: fix build warning
Date: Mon, 25 Jan 2016 11:43:09 +0530
Message-ID: <1453702389-601-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are getting build warning about:
macb.c:2889:13: warning: 'tx_clk' may be used uninitialized in this function
macb.c:2888:11: warning: 'hclk' may be used uninitialized in this function

In reality they are not used uninitialized as clk_init() will initialize
them, this patch will just silence the warning.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9d9984a..50c9410 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2823,7 +2823,7 @@ static int macb_probe(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node;
 	struct device_node *phy_node;
 	const struct macb_config *macb_config = NULL;
-	struct clk *pclk, *hclk, *tx_clk;
+	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
 	unsigned int queue_mask, num_queues;
 	struct macb_platform_data *pdata;
 	bool native_io;
-- 
1.9.1
