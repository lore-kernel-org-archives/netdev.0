From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2/3] defxx: DEFEA's Burst Holdoff register initialization
 fix
Date: Thu, 25 Sep 2014 11:06:45 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1409251031170.6148@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:51423 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaIYK3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 06:29:39 -0400
Received: from localhost.localdomain ([127.0.0.1]:35308 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S27009733AbaIYKGpwGQiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 12:06:45 +0200
In-Reply-To: <alpine.LFD.2.11.1409242337420.6148@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the mask rather than bit number macro to initialize the chip select 
control bit for PDQ register space decoding in the Burst Holdoff register.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Another brown paperbag.  Dave, please apply.

  Maciej

linux-defea-burst-holdoff.patch
Index: linux-20140924-dolch/drivers/net/fddi/defxx.c
===================================================================
--- linux-20140924-dolch.orig/drivers/net/fddi/defxx.c
+++ linux-20140924-dolch/drivers/net/fddi/defxx.c
@@ -748,9 +748,9 @@ static void dfx_bus_init(struct net_devi
 		 */
 		val = inb(base_addr + PI_DEFEA_K_BURST_HOLDOFF);
 		if (dfx_use_mmio)
-			val |= PI_BURST_HOLDOFF_V_MEM_MAP;
+			val |= PI_BURST_HOLDOFF_M_MEM_MAP;
 		else
-			val &= ~PI_BURST_HOLDOFF_V_MEM_MAP;
+			val &= ~PI_BURST_HOLDOFF_M_MEM_MAP;
 		outb(val, base_addr + PI_DEFEA_K_BURST_HOLDOFF);
 
 		/* Enable interrupts at EISA bus interface chip (ESIC) */
