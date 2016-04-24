From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: get rid of the 2nd parameter to sh_eth_dev_init()
Date: Sun, 24 Apr 2016 19:11:07 +0300
Message-ID: <1615196.r6Bb3HFTJZ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sh_eth_dev_init()  is now always called with  'true' as the  2nd argument,
so that there's no more sense in having 2 parameters to this function...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |   23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1229,7 +1229,7 @@ ring_free:
 	return -ENOMEM;
 }
 
-static int sh_eth_dev_init(struct net_device *ndev, bool start)
+static int sh_eth_dev_init(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int ret;
@@ -1279,10 +1279,8 @@ static int sh_eth_dev_init(struct net_de
 		     RFLR);
 
 	sh_eth_modify(ndev, EESR, 0, 0);
-	if (start) {
-		mdp->irq_enabled = true;
-		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
-	}
+	mdp->irq_enabled = true;
+	sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
 
 	/* PAUSE Prohibition */
 	sh_eth_write(ndev, ECMR_ZPF | (mdp->duplex ? ECMR_DM : 0) |
@@ -1295,8 +1293,7 @@ static int sh_eth_dev_init(struct net_de
 	sh_eth_write(ndev, mdp->cd->ecsr_value, ECSR);
 
 	/* E-MAC Interrupt Enable register */
-	if (start)
-		sh_eth_write(ndev, mdp->cd->ecsipr_value, ECSIPR);
+	sh_eth_write(ndev, mdp->cd->ecsipr_value, ECSIPR);
 
 	/* Set MAC address */
 	update_mac_address(ndev);
@@ -1309,10 +1306,8 @@ static int sh_eth_dev_init(struct net_de
 	if (mdp->cd->tpauser)
 		sh_eth_write(ndev, TPAUSER_UNLIMITED, TPAUSER);
 
-	if (start) {
-		/* Setting the Rx mode will start the Rx process. */
-		sh_eth_write(ndev, EDRRR_R, EDRRR);
-	}
+	/* Setting the Rx mode will start the Rx process. */
+	sh_eth_write(ndev, EDRRR_R, EDRRR);
 
 	return ret;
 }
@@ -2194,7 +2189,7 @@ static int sh_eth_set_ringparam(struct n
 				   __func__);
 			return ret;
 		}
-		ret = sh_eth_dev_init(ndev, true);
+		ret = sh_eth_dev_init(ndev);
 		if (ret < 0) {
 			netdev_err(ndev, "%s: sh_eth_dev_init failed.\n",
 				   __func__);
@@ -2246,7 +2241,7 @@ static int sh_eth_open(struct net_device
 		goto out_free_irq;
 
 	/* device init */
-	ret = sh_eth_dev_init(ndev, true);
+	ret = sh_eth_dev_init(ndev);
 	if (ret)
 		goto out_free_irq;
 
@@ -2299,7 +2294,7 @@ static void sh_eth_tx_timeout(struct net
 	}
 
 	/* device init */
-	sh_eth_dev_init(ndev, true);
+	sh_eth_dev_init(ndev);
 
 	netif_start_queue(ndev);
 }
