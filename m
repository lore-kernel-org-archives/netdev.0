From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 4/9] net: sh-eth: Remove duplicate sh_eth_set_duplex()
Date: Tue,  7 May 2013 14:17:50 +0900
Message-ID: <1367903875-32606-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:57882 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757346Ab3EGFST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:19 -0400
Received: by mail-pb0-f50.google.com with SMTP id um15so135769pbc.9
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:18 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  Remove sh_eth_set_duplex from SH7619, SH7710 and SH7712.
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.c |   57 +++------------------------------
 1 file changed, 4 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 334fa13..944b2df 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -341,9 +341,6 @@ static void sh_eth_select_mii(struct net_device *ndev)
 }
 #endif
 
-/* There is CPU dependent code */
-#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
-#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_duplex(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -354,6 +351,9 @@ static void sh_eth_set_duplex(struct net_device *ndev)
 		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
 }
 
+/* There is CPU dependent code */
+#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
+#define SH_ETH_RESET_DEFAULT	1
 static void sh_eth_set_rate(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -391,15 +391,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
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
@@ -443,16 +434,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
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
@@ -584,7 +555,7 @@ static void sh_eth_set_rate_giga(struct net_device *ndev)
 /* SH7757(GETHERC) */
 static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.chip_reset	= sh_eth_chip_reset_giga,
-	.set_duplex	= sh_eth_set_duplex_giga,
+	.set_duplex	= sh_eth_set_duplex,
 	.set_rate	= sh_eth_set_rate_giga,
 
 	.ecsr_value	= ECSR_ICD | ECSR_MPD,
@@ -635,16 +606,6 @@ static void sh_eth_chip_reset(struct net_device *ndev)
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
@@ -774,16 +735,6 @@ out:
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
-- 
1.7.10.4
