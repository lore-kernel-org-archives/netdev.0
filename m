From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH 1/3] PowerPC: ibm_newemac correct opb_bus_freq value
Date: Fri, 23 Nov 2007 22:10:19 +0300
Message-ID: <20071123191019.GA25685@ru.mvista.com>
References: <20071123190747.GA25654@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, jwboyer@linux.vnet.ibm.com
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:53000 "EHLO
	vaxon.spb.rtsoft.ru" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753492AbXKWTMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 14:12:48 -0500
Content-Disposition: inline
In-Reply-To: <20071123190747.GA25654@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The EMAC4_MR1_OBCI(freq) macro expects freg in MHz,
while opb_bus_freq is kept in Hz. Correct this.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/ibm_newemac/core.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

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
 
