From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: call sh_eth_tsu_write() from sh_eth_chip_reset_giga()
Date: Sun, 08 May 2016 00:08:05 +0300
Message-ID: <4295394.ciMgKzJDnu@wasted.cogentembedded.com>
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

sh_eth_chip_reset_giga() doesn't really need to use direct iowrite32() when
writing  to the ARSTR register,  it can use sh_eth_tsu_write() as all other
chip_reset() methods.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -725,8 +725,9 @@ static struct sh_eth_cpu_data sh7757_dat
 #define GIGA_MAHR(port)		(SH_GIGA_ETH_BASE + 0x800 * (port) + 0x05c0)
 static void sh_eth_chip_reset_giga(struct net_device *ndev)
 {
-	int i;
+	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 mahr[2], malr[2];
+	int i;
 
 	/* save MAHR and MALR */
 	for (i = 0; i < 2; i++) {
@@ -735,7 +736,7 @@ static void sh_eth_chip_reset_giga(struc
 	}
 
 	/* reset device */
-	iowrite32(ARSTR_ARST, (void *)(SH_GIGA_ETH_BASE + 0x1800));
+	sh_eth_tsu_write(mdp, ARSTR_ARST, ARSTR);
 	mdelay(1);
 
 	/* restore MAHR and MALR */
