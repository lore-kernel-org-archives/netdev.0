From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH 1/2] net: calexdaxgmac: fix printing of hardware version
Date: Sun, 10 Feb 2013 15:38:40 +0000
Message-ID: <1360510721-17860-2-git-send-email-ben.dooks@codethink.co.uk>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, Ben Dooks <ben.dooks@codethink.co.uk>,
 "David S. Miller" <davem@davemloft.net>, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The current driver attempts to print netdev_info() before registering the
network device and allowing the name to be set. Change this print to be
after the network deviec has been registered, and thus has been allocated
a network device name.

Fix the following issue:

calxedaxgmac fff50000.ethernet (unregistered net_device): h/w version is 0x1012

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 drivers/net/ethernet/calxeda/xgmac.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index f7f0290..f91d9b2 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1715,9 +1715,6 @@ static int xgmac_probe(struct platform_device *pdev)
 		goto err_io;
 	}
 
-	uid = readl(priv->base + XGMAC_VERSION);
-	netdev_info(ndev, "h/w version is 0x%x\n", uid);
-
 	writel(0, priv->base + XGMAC_DMA_INTR_ENA);
 	ndev->irq = platform_get_irq(pdev, 0);
 	if (ndev->irq == -ENXIO) {
@@ -1771,6 +1768,9 @@ static int xgmac_probe(struct platform_device *pdev)
 	if (ret)
 		goto err_reg;
 
+	uid = readl(priv->base + XGMAC_VERSION);
+	netdev_info(ndev, "h/w version is 0x%x\n", uid);
+
 	return 0;
 
 err_reg:
-- 
1.7.10.4
