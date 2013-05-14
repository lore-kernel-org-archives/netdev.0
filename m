From: Simon Horman <horms+renesas@verge.net.au>
Subject: [RFC PATCH net-next v2 2/3] sh_eth: add support RMIIMODE register
Date: Tue, 14 May 2013 11:37:52 +0900
Message-ID: <1368499073-21975-3-git-send-email-horms+renesas@verge.net.au>
References: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53336 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755684Ab3ENCiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 22:38:00 -0400
In-Reply-To: <1368499073-21975-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is motivated by the lager board which uses the r8a7790 SoC,
an R-Car SoC. For this board setting the RMIIMODE register is necessary.

This patch assumes this is valid for all R-Car SoCs.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

--

v2
* Split from patch to add r8a7790 support to driver (ifdef nastiness)
* As suggested by Sergei Shtylyov
  - Add a field to struct sh_eth_cpu_data to indicate if the
    rmiimode register is present. This replaces an extremely ugly ifdef.
---
 drivers/net/ethernet/renesas/sh_eth.c | 5 +++++
 drivers/net/ethernet/renesas/sh_eth.h | 2 ++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 016cf80..ff5613d 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -190,6 +190,7 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[RMCR]		= 0x0258,
 	[TFUCR]		= 0x0264,
 	[RFOCR]		= 0x0268,
+	[RMIIMODE]      = 0x026c,
 	[FCFTR]		= 0x0270,
 	[TRIMD]		= 0x027c,
 };
@@ -389,6 +390,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.mpr		= 1,
 	.tpauser	= 1,
 	.hw_swap	= 1,
+	.rmiimode	= 1,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7724)
 #define SH_ETH_RESET_DEFAULT	1
@@ -1276,6 +1278,9 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	if (ret)
 		goto out;
 
+	if (mdp->cd->rmiimode)
+		sh_eth_write(ndev, 0x1, RMIIMODE);
+
 	/* Descriptor format */
 	sh_eth_ring_format(ndev);
 	if (mdp->cd->rpadir)
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 1ddc9f2..1698bbd 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -60,6 +60,7 @@ enum {
 	EDOCR,
 	TFUCR,
 	RFOCR,
+	RMIIMODE,
 	FCFTR,
 	RPADIR,
 	TRIMD,
@@ -478,6 +479,7 @@ struct sh_eth_cpu_data {
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
 	unsigned hw_crc:1;	/* E-DMAC have CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
+	unsigned rmiimode:1;		/* EtherC has RMIIMODE register */
 };
 
 struct sh_eth_private {
-- 
1.8.2.1
