From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v4 3/8] sh_eth: remove duplicate sh_eth_set_duplex() definitions
Date: Thu, 6 Jun 2013 01:12:44 +0400
Message-ID: <201306060112.44714.sergei.shtylyov@cogentembedded.com>
References: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:37782 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932405Ab3FEVMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 17:12:41 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so1915099lab.30
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 14:12:39 -0700 (PDT)
In-Reply-To: <201306060106.51082.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
