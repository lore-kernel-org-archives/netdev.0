From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 3/4] defxx: Disable DEFEA's ESIC I/O decoding on shutdown
Date: Fri, 21 Nov 2014 14:10:02 +0000 (GMT)
Message-ID: <alpine.LFD.2.11.1411211227230.4773@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:59728 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758483AbaKUOKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 09:10:03 -0500
Received: from localhost.localdomain ([127.0.0.1]:49961 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27006529AbaKUOKC2KOU2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:10:02 +0100
In-Reply-To: <alpine.LFD.2.11.1411211107150.4773@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the option card does not respond after shutdown by disabling
it via ESIC's Expansion Board Control register.  Also disable memory and
port I/O decoders, the latter in particular to disable slot-specific I/O
decoding that otherwise remains active even in the board is disabled.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
linux-defea-bus-uninit.patch
Index: linux-20141025-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20141025-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20141025-dolch/drivers/net/fddi/defxx.c
@@ -856,6 +856,12 @@ static void dfx_bus_uninit(struct net_de
 		val = inb(base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
 		val &= ~PI_CONFIG_STAT_0_M_INT_ENB;
 		outb(val, base_addr + PI_ESIC_K_IO_CONFIG_STAT_0);
+
+		/* Disable the board.  */
+		outb(0, base_addr + PI_ESIC_K_SLOT_CNTRL);
+
+		/* Disable memory and port decoders.  */
+		outb(0, base_addr + PI_ESIC_K_FUNCTION_CNTRL);
 	}
 	if (dfx_bus_pci) {
 		/* Disable interrupts at PCI bus interface chip (PFI) */
