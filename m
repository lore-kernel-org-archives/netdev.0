From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH 3/5] ne: Add NEEDS_PORTLIST to control ISA auto-probe
Date: Tue, 01 May 2007 00:27:49 +0900 (JST)
Message-ID: <20070501.002749.21593079.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, ralf@linux-mips.org,
	sshtylyov@ru.mvista.com, akpm@linux-foundation.org
To: linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.175.29]:55150 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423367AbXD3P1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 11:27:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NEEDS_PORTLIST cpp macro to control ISA auto-probe.
(I'm not sure M32R needs auto-probe but it is current behavior)

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
 drivers/net/ne.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 32ae91b..22d6fe4 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -78,8 +78,13 @@ static const char version2[] =
 /* Do we have a non std. amount of memory? (in units of 256 byte pages) */
 /* #define PACKETBUF_MEMSIZE	0x40 */
 
+#if !defined(MODULE) && (defined(CONFIG_ISA) || defined(CONFIG_M32R))
+/* Do we need a portlist for the ISA auto-probe ? */
+#define NEEDS_PORTLIST
+#endif
+
 /* A zero-terminated list of I/O addresses to be probed at boot. */
-#ifndef MODULE
+#ifdef NEEDS_PORTLIST
 static unsigned int netcard_portlist[] __initdata = {
 	0x300, 0x280, 0x320, 0x340, 0x360, 0x380, 0
 };
@@ -186,7 +191,7 @@ static void ne_block_output(struct net_device *dev, const int count,
 static int __init do_ne_probe(struct net_device *dev)
 {
 	unsigned long base_addr = dev->base_addr;
-#ifndef MODULE
+#ifdef NEEDS_PORTLIST
 	int orig_irq = dev->irq;
 #endif
 
@@ -202,7 +207,7 @@ static int __init do_ne_probe(struct net_device *dev)
 	if (isapnp_present() && (ne_probe_isapnp(dev) == 0))
 		return 0;
 
-#ifndef MODULE
+#ifdef NEEDS_PORTLIST
 	/* Last resort. The semi-risky ISA auto-probe. */
 	for (base_addr = 0; netcard_portlist[base_addr] != 0; base_addr++) {
 		int ioaddr = netcard_portlist[base_addr];
