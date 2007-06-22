From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 1/9] pasemi_mac: Fix TX interrupt threshold
Date: Fri, 22 Jun 2007 15:04:54 -0500
Message-ID: <20070622200454.GB11723@lixom.net>
References: <20070622194720.614405000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:56557 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbXFVUMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 16:12:17 -0400
Content-Disposition: inline; filename=pasemi_mac-rx-intr-fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was mistakenly set to interrupt on the second packet instead of first, causing
some interesting latency behaviour.


Signed-off-by: Olof Johansson <olof@lixom.net>

Index: netdev-2.6/drivers/net/pasemi_mac.c
===================================================================
--- netdev-2.6.orig/drivers/net/pasemi_mac.c
+++ netdev-2.6/drivers/net/pasemi_mac.c
@@ -755,7 +755,7 @@ static int pasemi_mac_open(struct net_de
 	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			       PAS_IOB_DMA_RXCH_CFG_CNTTH(1));
+			       PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
 
 	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
 			       PAS_IOB_DMA_TXCH_CFG_CNTTH(32));

--
