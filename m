From: akpm@osdl.org
Subject: [patch 6/8] declance: Support the I/O ASIC LANCE w/o TURBOchannel
Date: Mon, 04 Dec 2006 15:04:55 -0800
Message-ID: <200612042306.kB4N64Gf008014@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, macro@linux-mips.org,
	ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:54447 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937454AbWLDXJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:09:39 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>

The onboard LANCE of I/O ASIC systems is not a TURBOchannel device, at
least from the software point of view.  Therefore it does not rely on any
kernel TURBOchannel bus services and can be supported even if support for
TURBOchannel has not been enabled in the configuration.

Tested with the onboard LANCE of a DECstation 5000/133.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/declance.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff -puN drivers/net/declance.c~declance-support-the-i-o-asic-lance-w-o-turbochannel drivers/net/declance.c
--- a/drivers/net/declance.c~declance-support-the-i-o-asic-lance-w-o-turbochannel
+++ a/drivers/net/declance.c
@@ -1065,7 +1065,6 @@ static int __init dec_lance_init(const i
 	lp->type = type;
 	lp->slot = slot;
 	switch (type) {
-#ifdef CONFIG_TC
 	case ASIC_LANCE:
 		dev->base_addr = CKSEG1ADDR(dec_kn_slot_base + IOASIC_LANCE);
 
@@ -1109,7 +1108,7 @@ static int __init dec_lance_init(const i
 			     CPHYSADDR(dev->mem_start) << 3);
 
 		break;
-
+#ifdef CONFIG_TC
 	case PMAD_LANCE:
 		claim_tc_card(slot);
 
@@ -1140,7 +1139,6 @@ static int __init dec_lance_init(const i
 
 		break;
 #endif
-
 	case PMAX_LANCE:
 		dev->irq = dec_interrupt[DEC_IRQ_LANCE];
 		dev->base_addr = CKSEG1ADDR(KN01_SLOT_BASE + KN01_LANCE);
@@ -1295,10 +1293,8 @@ static int __init dec_lance_probe(void)
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
_
