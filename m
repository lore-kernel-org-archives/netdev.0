From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: stmmac: fixed enh_desc set always zero
Date: Fri, 28 Jun 2013 16:35:32 +0900
Message-ID: <015801ce73d2$12332070$36996150$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:19324 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754779Ab3F1Hfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 03:35:33 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MP300FJFEF6CT20@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 28 Jun 2013 16:35:32 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch fixed that enh_desc value is always zero.
Due to calling order of stmmac_selec_desc_mode(), enh_desc value is always zero. 
Even though mac is set to use enhanced dma descriptor, if enh_desc is zero, 
functions related dma descriptor are not working correctly.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e5e221e..40efd55 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2567,9 +2567,6 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* Get and dump the chip ID */
 	priv->synopsys_id = stmmac_get_synopsys_id(priv);
 
-	/* To use alternate (extended) or normal descriptor structures */
-	stmmac_selec_desc_mode(priv);
-
 	/* To use the chained or ring mode */
 	if (chain_mode) {
 		priv->hw->chain = &chain_mode_ops;
@@ -2604,6 +2601,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	} else
 		pr_info(" No HW DMA feature register supported");
 
+	/* To use alternate (extended) or normal descriptor structures */
+	stmmac_selec_desc_mode(priv);
+
 	ret = priv->hw->mac->rx_ipc(priv->ioaddr);
 	if (!ret) {
 		pr_warn(" RX IPC Checksum Offload not configured.\n");
-- 
1.7.10.4
