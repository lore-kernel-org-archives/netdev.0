From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: [PATCH V2 07/10] net: ethernet: xilinx: Generate random mac if none found
Date: Thu, 18 Aug 2016 14:43:21 +0100
Message-ID: <1471527804-26175-8-git-send-email-Zubair.Kakakhel@imgtec.com>
References: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jason@lakedaemon.net>, <marc.zyngier@arm.com>,
        <linux-mips@linux-mips.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>, <Zubair.Kakakhel@imgtec.com>
To: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

At the moment, if the emaclite device doesn't find a mac address
from any source, it simply uses 0x0 with a warning printed.

Instead of using a 0x0 mac address, use a randomly generated one.

Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>

---
V1 -> V2
New patch
---
 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 3cee84a..22e5a5a 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -1134,8 +1134,10 @@ static int xemaclite_of_probe(struct platform_device *ofdev)
 	if (mac_address)
 		/* Set the MAC address. */
 		memcpy(ndev->dev_addr, mac_address, ETH_ALEN);
-	else
-		dev_warn(dev, "No MAC address found\n");
+	else {
+		dev_warn(dev, "No MAC address found. Generating Random one\n");
+		eth_hw_addr_random(ndev);
+	}
 
 	/* Clear the Tx CSR's in case this is a restart */
 	__raw_writel(0, lp->base_addr + XEL_TSR_OFFSET);
-- 
1.9.1
