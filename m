From: Andrew Victor <andrew@sanpeople.com>
Subject: [PATCH 2.6.21] AT91RM9200 Ethernet: Fix multicast addressing
Date: 02 May 2007 12:11:38 +0200
Message-ID: <1178100698.14657.8.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from za-gw.sanpeople.com ([196.211.225.226]:2772 "EHLO
	za-gw.sanpeople.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993020AbXEBKeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 06:34:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The order that the two 32-bit words written to the Hash Address (Low,
High) Registers for matching of multicast addresses is incorrect.

Signed-off-by: Lars Reemts <Lars.Reemts@entwicklung.eq-3.de>
Signed-off-by: Andrew Victor <andrew@sanpeople.com>


diff -urN linux-2.6.21/drivers/net/arm/at91_ether.c linux-2.6.21.new/drivers/net/arm/at91_ether.c
--- linux-2.6.21/drivers/net/arm/at91_ether.c	Thu Apr 26 05:08:32 2007
+++ linux-2.6.21.new/drivers/net/arm/at91_ether.c	Wed May  2 12:03:21 2007
@@ -535,8 +535,8 @@
 		mc_filter[bitnr >> 5] |= 1 << (bitnr & 31);
 	}
 
-	at91_emac_write(AT91_EMAC_HSH, mc_filter[0]);
-	at91_emac_write(AT91_EMAC_HSL, mc_filter[1]);
+	at91_emac_write(AT91_EMAC_HSL, mc_filter[0]);
+	at91_emac_write(AT91_EMAC_HSH, mc_filter[1]);
 }
 
 /*



