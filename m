From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: re-enable-E-MAC interrupts in sh_eth_set_ringparam()
Date: Sun, 10 Apr 2016 02:28:41 +0300
Message-ID: <2542968.R3YjY2kHV4@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The E-MAC interrupts are left disabled when the ring parameters are changed
via 'ethtool'. In order to fix this, it's enough to call sh_eth_dev_init()
with 'true' instead of 'false' for the second argument (which conveniently
allows us to remove the following code re-enabling E-DMAC interrupts and
reception).

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -2194,17 +2194,13 @@ static int sh_eth_set_ringparam(struct n
 				   __func__);
 			return ret;
 		}
-		ret = sh_eth_dev_init(ndev, false);
+		ret = sh_eth_dev_init(ndev, true);
 		if (ret < 0) {
 			netdev_err(ndev, "%s: sh_eth_dev_init failed.\n",
 				   __func__);
 			return ret;
 		}
 
-		mdp->irq_enabled = true;
-		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
-		/* Setting the Rx mode will start the Rx process. */
-		sh_eth_write(ndev, EDRRR_R, EDRRR);
 		netif_device_attach(ndev);
 	}
 
