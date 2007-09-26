From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [3/6] pasemi_mac: set interface speed correctly on XAUI
	ports
Date: Wed, 26 Sep 2007 16:23:31 -0500
Message-ID: <20070926212331.GD24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49440 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761702AbXIZVUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:20:22 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: set interface speed correctly on XAUI ports

Set interface speed for XAUI to 10G per default, not 1G.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: 2.6.23/drivers/net/pasemi_mac.c
===================================================================
--- 2.6.23.orig/drivers/net/pasemi_mac.c
+++ 2.6.23/drivers/net/pasemi_mac.c
@@ -794,7 +794,10 @@ static int pasemi_mac_open(struct net_de
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
 
-	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
+	if (mac->type == MAC_TYPE_GMAC)
+		flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
+	else
+		flags |= PAS_MAC_CFG_PCFG_TSR_10G | PAS_MAC_CFG_PCFG_SPD_10G;
 
 	write_iob_reg(mac, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
 			   PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
