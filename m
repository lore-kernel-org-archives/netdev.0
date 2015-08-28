From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: propagate platform_get_irq() error upstream
Date: Fri, 28 Aug 2015 16:56:01 +0300
Message-ID: <1774140.R12mtes975@wasted.cogentembedded.com>
References: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, horms@verge.net.au
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <9944836.IRPmWk4iN8@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver overrides the error returned by platform_get_irq() with -ENODEV
which e.g. precludes the deferred  probing from working. Propagate the real
error code to the driver core instead.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -3089,10 +3089,8 @@ static int sh_eth_drv_probe(struct platf
 
 	ndev->dma = -1;
 	ret = platform_get_irq(pdev, 0);
-	if (ret < 0) {
-		ret = -ENODEV;
+	if (ret < 0)
 		goto out_release;
-	}
 	ndev->irq = ret;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);

