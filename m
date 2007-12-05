From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 8/11] ibm_newemac: Correct opb_bus_freq value
Date: Wed, 05 Dec 2007 11:14:31 +1100
Message-ID: <20071205001540.6CA77DE0BE@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51523 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbXLEAQG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 19:16:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentine Barshak <vbarshak@ru.mvista.com>

The EMAC4_MR1_OBCI(freq) macro expects freg in MHz,
while opb_bus_freq is kept in Hz. Correct this.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.c linux-2.6/drivers/net/ibm_newemac/core.c
--- linux-2.6.orig/drivers/net/ibm_newemac/core.c	2007-11-23 21:27:57.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.c	2007-11-23 21:47:53.000000000 +0300
@@ -402,7 +402,7 @@ static u32 __emac_calc_base_mr1(struct e
 static u32 __emac4_calc_base_mr1(struct emac_instance *dev, int tx_size, int rx_size)
 {
 	u32 ret = EMAC_MR1_VLE | EMAC_MR1_IST | EMAC4_MR1_TR |
-		EMAC4_MR1_OBCI(dev->opb_bus_freq);
+		EMAC4_MR1_OBCI(dev->opb_bus_freq / 1000000);
 
 	DBG2(dev, "__emac4_calc_base_mr1" NL);
 

