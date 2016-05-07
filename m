From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: reuse sh_eth_chip_reset()
Date: Sat, 07 May 2016 14:09:01 -0700 (PDT)
Message-ID: <17855885.Wjh3NaxovJ@wasted.cogentembedded.com>
References: <1808900.MGlUzc8O9C@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1808900.MGlUzc8O9C@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All the chip_reset() methods repeat the code writing to the ARSTR register
and delaying for 1 ms, so that we can reuse sh_eth_chip_reset() twice.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -537,11 +537,7 @@ static struct sh_eth_cpu_data r7s72100_d
 
 static void sh_eth_chip_reset_r8a7740(struct net_device *ndev)
 {
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARST, ARSTR);
-	mdelay(1);
+	sh_eth_chip_reset(ndev);
 
 	sh_eth_select_mii(ndev);
 }
@@ -725,7 +721,6 @@ static struct sh_eth_cpu_data sh7757_dat
 #define GIGA_MAHR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c0)
 static void sh_eth_chip_reset_giga(struct net_device *ndev)
 {
-	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 mahr[2], malr[2];
 	int i;
 
@@ -735,9 +730,7 @@ static void sh_eth_chip_reset_giga(struc
 		mahr[i] = ioread32((void *)GIGA_MAHR(i));
 	}
 
-	/* reset device */
-	sh_eth_tsu_write(mdp, ARSTR_ARST, ARSTR);
-	mdelay(1);
+	sh_eth_chip_reset(ndev);
 
 	/* restore MAHR and MALR */
 	for (i = 0; i < 2; i++) {
