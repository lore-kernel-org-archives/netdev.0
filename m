From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18] declance: Support the I/O ASIC LANCE w/o TURBOchannel
Date: Thu, 30 Nov 2006 13:15:05 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0611301306460.1757@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:26635 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S936390AbWK3NPJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 08:15:09 -0500
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The onboard LANCE of I/O ASIC systems is not a TURBOchannel device, at 
least from the software point of view.  Therefore it does not rely on any 
kernel TURBOchannel bus services and can be supported even if support for 
TURBOchannel has not been enabled in the configuration.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Tested with the onboard LANCE of a DECstation 5000/133.

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-declance-tc-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/declance.c linux-mips-2.6.18-20060920/drivers/net/declance.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/declance.c	2006-11-23 02:55:34.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/declance.c	2006-11-30 02:31:19.000000000 +0000
@@ -1068,7 +1068,6 @@ static int __init dec_lance_init(const i
 	lp->type = type;
 	lp->slot = slot;
 	switch (type) {
-#ifdef CONFIG_TC
 	case ASIC_LANCE:
 		dev->base_addr = CKSEG1ADDR(dec_kn_slot_base + IOASIC_LANCE);
 
@@ -1112,7 +1111,7 @@ static int __init dec_lance_init(const i
 			     CPHYSADDR(dev->mem_start) << 3);
 
 		break;
-
+#ifdef CONFIG_TC
 	case PMAD_LANCE:
 		claim_tc_card(slot);
 
@@ -1143,7 +1142,6 @@ static int __init dec_lance_init(const i
 
 		break;
 #endif
-
 	case PMAX_LANCE:
 		dev->irq = dec_interrupt[DEC_IRQ_LANCE];
 		dev->base_addr = CKSEG1ADDR(KN01_SLOT_BASE + KN01_LANCE);
@@ -1298,10 +1296,8 @@ static int __init dec_lance_probe(void)
 	/* Then handle onboard devices. */
 	if (dec_interrupt[DEC_IRQ_LANCE] >= 0) {
 		if (dec_interrupt[DEC_IRQ_LANCE_MERR] >= 0) {
-#ifdef CONFIG_TC
 			if (dec_lance_init(ASIC_LANCE, -1) >= 0)
 				count++;
-#endif
 		} else if (!TURBOCHANNEL) {
 			if (dec_lance_init(PMAX_LANCE, -1) >= 0)
 				count++;
