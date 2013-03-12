From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] ethernet: nxp: use resource_size()
Date: Tue, 12 Mar 2013 20:30:35 +0200
Message-ID: <1363113035-11269-1-git-send-email-silviupopescu1990@gmail.com>
Cc: davem@davemloft.net, stigge@antcom.de, edumazet@google.com,
	gregkh@linuxfoundation.org, jiri@resnulli.us,
	linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use resource_size() instead of explicit calculation. This was found via
make coccicheck.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index c4122c8..bc493c8 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1362,7 +1362,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Map IO space */
-	pldat->net_base = ioremap(res->start, res->end - res->start + 1);
+	pldat->net_base = ioremap(res->start, resource_size(res));
 	if (!pldat->net_base) {
 		dev_err(&pdev->dev, "failed to map registers\n");
 		ret = -ENOMEM;
@@ -1421,7 +1421,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	netdev_dbg(ndev, "IO address start     :0x%08x\n",
 			res->start);
 	netdev_dbg(ndev, "IO address size      :%d\n",
-			res->end - res->start + 1);
+			resource_size(res));
 	netdev_dbg(ndev, "IO address (mapped)  :0x%p\n",
 			pldat->net_base);
 	netdev_dbg(ndev, "IRQ number           :%d\n", ndev->irq);
-- 
1.7.9.5
