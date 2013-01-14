From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] drivers/net: Clean up orphaned probes in Space.c
Date: Sun, 13 Jan 2013 23:55:05 -0500
Message-ID: <1358139305-17737-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58448 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab3ANE4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 23:56:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The removal of the 8390 EISA drivers actually comprises the
complete content of the EISA probe block, so we can now remove
that block, and its hook into the unified probe.  Note that
the deleted comment mentions PCI probes, but they long since
moved elsewhere, so no PCI probes are touched here.

We get rid of the orphaned EISA probe prototypes, and a couple
of left over MCA probe prototypes at the same time.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index e3f0fac..5637c26 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -37,10 +37,8 @@
    ethernet adaptor have the name "eth[0123...]".
    */
 
-extern struct net_device *ne2_probe(int unit);
 extern struct net_device *hp100_probe(int unit);
 extern struct net_device *ultra_probe(int unit);
-extern struct net_device *ultra32_probe(int unit);
 extern struct net_device *wd_probe(int unit);
 extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
@@ -55,11 +53,7 @@ extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *el1_probe(int unit);
 extern struct net_device *el16_probe(int unit);
-extern struct net_device *elmc_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
-extern struct net_device *ac3200_probe(int unit);
-extern struct net_device *es_probe(int unit);
-extern struct net_device *lne390_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
 extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni52_probe(int unit);
@@ -77,7 +71,6 @@ extern struct net_device *tc515_probe(int unit);
 extern struct net_device *lance_probe(int unit);
 extern struct net_device *mac8390_probe(int unit);
 extern struct net_device *mac89x0_probe(int unit);
-extern struct net_device *mc32_probe(int unit);
 extern struct net_device *cops_probe(int unit);
 extern struct net_device *ltpc_probe(void);
 
@@ -111,29 +104,6 @@ static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
 }
 
 /*
- * This is a bit of an artificial separation as there are PCI drivers
- * that also probe for EISA cards (in the PCI group) and there are ISA
- * drivers that probe for EISA cards (in the ISA group).  These are the
- * legacy EISA only driver probes, and also the legacy PCI probes
- */
-
-static struct devprobe2 eisa_probes[] __initdata = {
-#ifdef CONFIG_ULTRA32
-	{ultra32_probe, 0},
-#endif
-#ifdef CONFIG_AC3200
-	{ac3200_probe, 0},
-#endif
-#ifdef CONFIG_ES3210
-	{es_probe, 0},
-#endif
-#ifdef CONFIG_LNE390
-	{lne390_probe, 0},
-#endif
-	{NULL, 0},
-};
-
-/*
  * ISA probes that touch addresses < 0x400 (including those that also
  * look for EISA/PCI cards in addition to ISA cards).
  */
@@ -264,7 +234,6 @@ static void __init ethif_probe2(int unit)
 		return;
 
 	(void)(	probe_list2(unit, m68k_probes, base_addr == 0) &&
-		probe_list2(unit, eisa_probes, base_addr == 0) &&
 		probe_list2(unit, isa_probes, base_addr == 0) &&
 		probe_list2(unit, parport_probes, base_addr == 0));
 }
-- 
1.8.1
