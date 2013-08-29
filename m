From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: no need to call ether_setup()
Date: Fri, 30 Aug 2013 00:24:47 +0400
Message-ID: <201308300024.48415.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need to call ether_setup() in the driver since prior alloc_etherdev()
call already arranges for it.

Suggested-by: Denis Kirjanov <kda@linux-powerpc.org>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    3 ---
 1 file changed, 3 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2639,9 +2639,6 @@ static int sh_eth_drv_probe(struct platf
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
-	/* Fill in the fields of the device structure with ethernet values. */
-	ether_setup(ndev);
-
 	mdp = netdev_priv(ndev);
 	mdp->num_tx_ring = TX_RING_SIZE;
 	mdp->num_rx_ring = RX_RING_SIZE;
