From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 6/8] net: sh-eth: Add irq configureation flags in sh_eth_cpu_data
Date: Thu, 18 Apr 2013 16:01:48 +0900
Message-ID: <1366268510-8121-6-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:55925 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab3DRHCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 03:02:16 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so1325134pdi.21
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 00:02:15 -0700 (PDT)
In-Reply-To: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sh-eth is supporting some SH and shmobile CPU. CPU with two or more networked
devices is in these, these specify IRQF_SHARED as IRQ configureation flags.
This changes to set IRQ configureation flags using in sh_eth_cpu_data.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   12 ++++--------
 drivers/net/ethernet/renesas/sh_eth.h |    2 ++
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index af8c225..a4e337f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -468,6 +468,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 			  EESR_RFRMER | EESR_TFE | EESR_TDE | EESR_ECI,
 	.tx_error_check	= EESR_TWB | EESR_TABT | EESR_TDE | EESR_TFE,
 
+	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
@@ -576,6 +577,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.fdr_value	= 0x0000072f,
 	.rmcr_value	= 0x00000001,
 
+	.irq_flags	= IRQF_SHARED,
 	.apr		= 1,
 	.mpr		= 1,
 	.tpauser	= 1,
@@ -658,6 +660,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.hw_crc     = 1,
 	.select_mii = 1,
 #else
+	.irq_flags	= IRQF_SHARED,
 	.tsu_multi_reg	= 1,
 #endif
 };
@@ -1920,14 +1923,7 @@ static int sh_eth_open(struct net_device *ndev)
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
-#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
-	defined(CONFIG_CPU_SUBTYPE_SH7757)
-				IRQF_SHARED,
-#else
-				0,
-#endif
-				ndev->name, ndev);
+				mdp->cd->irq_flags, ndev->name, ndev);
 	if (ret) {
 		dev_err(&ndev->dev, "Can not assign IRQ number\n");
 		return ret;
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index f86ea96..0772ec1 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -463,6 +463,7 @@ struct sh_eth_cpu_data {
 	unsigned long tx_error_check;
 
 	/* hardware features */
+	unsigned long irq_flags; /* IRQ configuration flags */
 	unsigned no_psr:1;		/* EtherC DO NOT have PSR */
 	unsigned apr:1;			/* EtherC have APR */
 	unsigned mpr:1;			/* EtherC have MPR */
@@ -508,6 +509,7 @@ struct sh_eth_private {
 	int duplex;
 	int port;		/* for TSU */
 	int vlan_num_ids;	/* for VLAN tag filter */
+	unsigned long irq_flags; /* IRQ configuration flags */
 
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
-- 
1.7.10.4
