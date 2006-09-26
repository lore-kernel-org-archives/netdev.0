From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/4] ethtool: don't show sync queue's on skge/sky2
Date: Tue, 26 Sep 2006 13:10:00 -0700
Message-ID: <20060926131000.08a67c89@freekitty>
References: <20060926115437.11ed1f85@freekitty>
	<451AF4B1.2000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30387 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031191AbWI0Wy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:54:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451AF4B1.2000208@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove printout of synchronous transmit queue info because
it is unused by the driver.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/marvell.c b/marvell.c
index 08fdbd9..373ebcf 100644
--- a/marvell.c
+++ b/marvell.c
@@ -174,12 +174,12 @@ int skge_dump_regs(struct ethtool_drvinf
 	printf("\nBus Management Unit\n");
 	printf("-------------------\n");
 	printf("CSR Receive Queue 1              0x%08X\n", r[24]);
-	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
+//	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
 	printf("CSR Async Queue 1                0x%08X\n", r[27]);
 	if (dual) {
 		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
 		printf("CSR Async Queue 2                0x%08X\n", r[29]);
-		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
+//		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
 	}
 
 	dump_mac(regs->data);
@@ -190,11 +190,11 @@ int skge_dump_regs(struct ethtool_drvinf
 	dump_timer("Blink Source", regs->data +0x170);
 
 	dump_queue("Receive Queue 1", regs->data +0x400, 1);
-	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
+//	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue("Async Transmit Queue 1", regs->data +0x680, 0);
 
 	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
-	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
+//	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
 	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
 
 	dump_fifo("Receive MAC FIFO 1", regs->data+0xc00);
@@ -204,10 +204,10 @@ int skge_dump_regs(struct ethtool_drvinf
 
 		dump_queue("Receive Queue 2", regs->data +0x480, 1);
 		dump_queue("Async Transmit Queue 2", regs->data +0x780, 0);
-		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
+//		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
 
 		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
-		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
+//		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
 
 		dump_fifo("Receive MAC FIFO 2", regs->data+0xc80);
@@ -282,14 +282,14 @@ int sky2_dump_regs(struct ethtool_drvinf
 	printf("\nBus Management Unit\n");
 	printf("-------------------\n");
 	printf("CSR Receive Queue 1              0x%08X\n", r[24]);
-	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
+//	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
 	printf("CSR Async Queue 1                0x%08X\n", r[27]);
 
 	dual = (regs->data[0x11e] & 2) != 0;
 	if (dual) {
 		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
 		printf("CSR Async Queue 2                0x%08X\n", r[29]);
-		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
+//		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
 	}
 
 	dump_mac(regs->data);
@@ -324,17 +324,17 @@ int sky2_dump_regs(struct ethtool_drvinf
 	dump_timer("ISR", regs->data + 0xed0);
 
 	dump_queue2("Receive Queue 1", regs->data +0x400, 1);
-	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
+//	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue2("Async Transmit Queue 1", regs->data +0x680, 0);
 
 
 	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
-	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
+//	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
 	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
 
 	if (dual) {
 		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
-		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
+//		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
 		dump_gmac("GMAC 2", regs->data + 0x3800);
 	}
-- 
1.4.1

