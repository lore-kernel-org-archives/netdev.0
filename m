From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: get rid of 'sh_eth_cpu_data::shift_rd0'
Date: Sat, 07 Jan 2017 00:02:52 +0300
Message-ID: <2242796.vvdcWWhAz4@wasted.cogentembedded.com>
References: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35683 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdAFVDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:03:34 -0500
Received: by mail-lf0-f46.google.com with SMTP id m78so39866712lfg.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 13:02:55 -0800 (PST)
In-Reply-To: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After checking all  the available manuals,  I have enough information to
conclude  that the 'shift_rd0' flag is only relevant  for the Ether cores
supporting so called "intelligent checksum" (and hence having CSMR) which
is indicated  by the 'hw_crc' flag.  Since  all the relevant SoCs now have
both these flags set, we can  at last  get  rid of the former flag...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    5 +----
 drivers/net/ethernet/renesas/sh_eth.h |    1 -
 2 files changed, 1 insertion(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -537,7 +537,6 @@ static struct sh_eth_cpu_data r7s72100_d
 	.no_ade		= 1,
 	.hw_crc		= 1,
 	.tsu		= 1,
-	.shift_rd0	= 1,
 };
 
 static void sh_eth_chip_reset_r8a7740(struct net_device *ndev)
@@ -577,7 +576,6 @@ static struct sh_eth_cpu_data r8a7740_da
 	.hw_crc		= 1,
 	.tsu		= 1,
 	.select_mii	= 1,
-	.shift_rd0	= 1,
 };
 
 /* There is CPU dependent code */
@@ -820,7 +818,6 @@ static struct sh_eth_cpu_data sh7734_dat
 	.tsu		= 1,
 	.hw_crc		= 1,
 	.select_mii	= 1,
-	.shift_rd0	= 1,
 };
 
 /* SH7763 */
@@ -1421,7 +1418,7 @@ static int sh_eth_rx(struct net_device *
 		 * the RFS bits are from bit 25 to bit 16. So, the
 		 * driver needs right shifting by 16.
 		 */
-		if (mdp->cd->shift_rd0)
+		if (mdp->cd->hw_crc)
 			desc_status >>= 16;
 
 		skb = mdp->rx_skbuff[entry];
Index: net/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net/drivers/net/ethernet/renesas/sh_eth.h
@@ -490,7 +490,6 @@ struct sh_eth_cpu_data {
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
 	unsigned hw_crc:1;	/* E-DMAC have CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
-	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
 	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
 	unsigned rtrate:1;	/* EtherC has RTRATE register */
 };
