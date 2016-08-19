From: Daniel Romell <danielromell@gmail.com>
Subject: [PATCH] net: xilinx: emaclite: Fallback to random MAC address.
Date: Fri, 19 Aug 2016 14:12:01 +0200
Message-ID: <1471608721-26984-1-git-send-email-daro@hms.se>
Cc: soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, mago@hms.se,
        Daniel Romell <daro@hms.se>
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the address configured in the device tree is invalid, the
driver will fallback to using a random address from the locally
administered range.

Signed-off-by: Daniel Romell <daro@hms.se>
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 3cee84a..93dc10b 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1131,11 +1131,13 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	lp->rx_ping_pong = get_bool(ofdev, "xlnx,rx-ping-pong");
 	mac_address = of_get_mac_address(ofdev->dev.of_node);
 
-	if (mac_address)
+	if (mac_address) {
 		/* Set the MAC address. */
 		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
-	else
-		dev_warn(dev, "No MAC address found\n");
+	} else {
+		dev_warn(dev, "No MAC address found, using random\n");
+		eth_hw_addr_random(ndev);
+	}
 
 	/* Clear the Tx CSR's in case this is a restart */
 	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
-- 
2.7.4
