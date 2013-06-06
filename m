From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 3/8] sh_eth: remove duplicate sh_eth_set_duplex() definitions
Date: Thu, 6 Jun 2013 23:45:25 +0400
Message-ID: <201306062345.26098.sergei.shtylyov@cogentembedded.com>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Remove all the duplicate definitions of sh_eth_set_duplex() under  different
#ifdef's, leaving only one outside the #ifdef's. We have to annotate it with
'__maybe_unused' since it's called not from all SoC #ifdef blocks.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: annotated sh_eth_set_duplex() as '__maybe_unused', added the changelog,
reworded the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- annotated sh_eth_set_duplex() as '__maybe_unused';
- refreshed the patch;
- added the changelog;
- reworded the subject, changing the prefix.

Changes in version 3:
- remove empty sh_eth_set_duplex() for SH7619, SH7710 and SH7712 cases.

 drivers/net/ethernet/renesas/sh_eth.c |   59 ++--------------------------------
 1 file changed, 5 insertions(+), 54 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -341,10 +341,7 @@ static void sh_eth_select_mii(struct net
 }
 #endif
 
-/* There is CPU dependent code */
-#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
-#define SH_ETH_RESET_DEFAULT	1
-static void sh_eth_set_duplex(struct net_device *ndev)
+static void __maybe_unused sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
@@ -354,6 +351,9 @@ static void sh_eth_set_duplex(struct net
 		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }
 
+/* There is CPU dependent code */
+#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
+#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -391,15 +391,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7724)
 #define SH_ETH_RESET_DEFAULT	1
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
 
 static void sh_eth_set_rate(struct net_device *ndev)
 {
@@ -443,16 +434,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 #define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -552,16 +533,6 @@ out:
 	return ret;
 }
 
-static void sh_eth_set_duplex_giga(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate_giga(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -584,7 +555,7 @@ static void sh_eth_set_rate_giga(struct 
 /* SH7757(GETHERC) */
 static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.chip_reset	= sh_eth_chip_reset_giga,
-	.set_duplex	= sh_eth_set_duplex_giga,
+	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_giga,
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
@@ -634,16 +605,6 @@ static void sh_eth_chip_reset(struct net
 	mdelay(1);
 }
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -771,16 +732,6 @@ out:
 	return ret;
 }
 
-static void sh_eth_set_duplex(struct net_device *ndev)
-{
-	struct sh_eth_private *mdp = netdev_priv(ndev);
-
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
-}
-
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
