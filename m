From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [Patch v5 1/2] net: ethernet: xilinx: Generate random mac if none found
Date: Fri, 2 Sep 2016 12:39:25 +0100
Message-ID: <1472816366-1018-2-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <Zubair.Kakakhel@imgtec.com>
To: <davem@davemloft.net>, <michal.simek@xilinx.com>,
        <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472816366-1018-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At the moment, if the emaclite device doesn't find a mac address
from any source, it simply uses 0x0 with a warning printed.

Instead of using a 0x0 mac address, use a randomly generated one.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V3 -> V4
Curly braces after if check for correct styling

V2 -> V3
No change

V1 -> V2
New patch
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 3cee84a..efc8d2e 100644
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
+		dev_warn(dev, "No MAC address found. Generating Random one\n");
+		eth_hw_addr_random(ndev);
+	}
 
 	/* Clear the Tx CSR's in case this is a restart */
 	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
-- 
1.9.1
