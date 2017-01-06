From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: rename 'sh_eth_cpu_data::hw_crc'
Date: Sat, 07 Jan 2017 00:03:37 +0300
Message-ID: <2080510.zUc1S61HLy@wasted.cogentembedded.com>
References: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34878 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755918AbdAFVDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:03:42 -0500
Received: by mail-lf0-f42.google.com with SMTP id m78so39877836lfg.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 13:03:41 -0800 (PST)
In-Reply-To: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'struct sh_eth_cpu_data' field indicating the "intelligent checksum"
support was misnamed 'hw_crc' -- rename it to 'hw_checksum'.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   12 ++++++------
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -535,7 +535,7 @@ static struct sh_eth_cpu_data r7s72100_d
 	.rpadir_value   = 2 << 16,
 	.no_trimd	= 1,
 	.no_ade		= 1,
-	.hw_crc		= 1,
+	.hw_checksum	= 1,
 	.tsu		= 1,
 };
 
@@ -573,7 +573,7 @@ static struct sh_eth_cpu_data r8a7740_da
 	.rpadir_value   = 2 << 16,
 	.no_trimd	= 1,
 	.no_ade		= 1,
-	.hw_crc		= 1,
+	.hw_checksum	= 1,
 	.tsu		= 1,
 	.select_mii	= 1,
 };
@@ -816,7 +816,7 @@ static struct sh_eth_cpu_data sh7734_dat
 	.no_trimd	= 1,
 	.no_ade		= 1,
 	.tsu		= 1,
-	.hw_crc		= 1,
+	.hw_checksum	= 1,
 	.select_mii	= 1,
 };
 
@@ -933,7 +933,7 @@ static int sh_eth_reset(struct net_devic
 		sh_eth_write(ndev, 0x0, RDFFR);
 
 		/* Reset HW CRC register */
-		if (mdp->cd->hw_crc)
+		if (mdp->cd->hw_checksum)
 			sh_eth_write(ndev, 0x0, CSMR);
 
 		/* Select MII mode */
@@ -1418,7 +1418,7 @@ static int sh_eth_rx(struct net_device *
 		 * the RFS bits are from bit 25 to bit 16. So, the
 		 * driver needs right shifting by 16.
 		 */
-		if (mdp->cd->hw_crc)
+		if (mdp->cd->hw_checksum)
 			desc_status >>= 16;
 
 		skb = mdp->rx_skbuff[entry];
@@ -1986,7 +1986,7 @@ static size_t __sh_eth_get_regs(struct n
 	add_reg(MAFCR);
 	if (cd->rtrate)
 		add_reg(RTRATE);
-	if (cd->hw_crc)
+	if (cd->hw_checksum)
 		add_reg(CSMR);
 	if (cd->select_mii)
 		add_reg(RMII_MII);
Index: net/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net/drivers/net/ethernet/renesas/sh_eth.h
@@ -488,7 +488,7 @@ struct sh_eth_cpu_data {
 	unsigned rpadir:1;	/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;	/* E-DMAC DO NOT have TRIMD */
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
-	unsigned hw_crc:1;	/* E-DMAC have CSMR */
+	unsigned hw_checksum:1;	/* E-DMAC has CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
 	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
 	unsigned rtrate:1;	/* EtherC has RTRATE register */
