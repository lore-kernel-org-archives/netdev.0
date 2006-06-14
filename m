From: Philip Craig <philipc@snapgear.com>
Subject: [PATCH 1/2] 8139cp: fix eeprom read command length
Date: Wed, 14 Jun 2006 16:43:01 +1000
Message-ID: <448FAFF5.7040701@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:40068 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S964784AbWFNGnI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 02:43:08 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The read command for the 93C46/93C56 EEPROMS should be 3 bits plus
the address.  This doesn't appear to affect the operation of the
read command, but similar errors for write commands do cause failures.

Signed-off-by: Philip Craig <philipc@snapgear.com>

Index: linux-2.6.17-rc6/drivers/net/8139cp.c
===================================================================
--- linux-2.6.17-rc6.orig/drivers/net/8139cp.c	2006-06-14 16:02:00.000000000 +1000
+++ linux-2.6.17-rc6/drivers/net/8139cp.c	2006-06-14 16:03:29.000000000 +1000
@@ -1628,7 +1628,7 @@ static int read_eeprom (void __iomem *io
 	eeprom_delay ();

 	/* Shift the read command bits out. */
-	for (i = 4 + addr_len; i >= 0; i--) {
+	for (i = 3 + addr_len - 1; i >= 0; i--) {
 		int dataval = (read_cmd & (1 << i)) ? EE_DATA_WRITE : 0;
 		writeb (EE_ENB | dataval, ee_addr);
 		eeprom_delay ();
