From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] ethtool: sky2 more decode
Date: Wed, 18 Oct 2006 10:47:44 -0700
Message-ID: <20061018104744.2ef54f21@freekitty>
References: <20061018104632.27a37d75@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54238 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751486AbWJRRvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 13:51:04 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061018104632.27a37d75@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dump even more GMAC/GPHY state

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/marvell.c b/marvell.c
index 244bb69..e867521 100644
--- a/marvell.c
+++ b/marvell.c
@@ -113,7 +113,7 @@ static void dump_fifo(const char *name, 
 	dump_timer("LED", p + 0x20);
 }
 
-static void dump_gmac_fifo(const void *p)
+static void dump_gmac_fifo(const char *name, const void *p)
 {
 	const u32 *r = p;
 	int i;
@@ -133,6 +133,7 @@ static void dump_gmac_fifo(const void *p
 		"FIFO Read Level",
 	};
 
+	printf("\n%s\n", name);
 	for (i = 0; i < sizeof(regs)/sizeof(regs[0]); ++i)
 		printf("%-32s 0x%08X\n", regs[i], r[i]);
 
@@ -319,8 +320,6 @@ int sky2_dump_regs(struct ethtool_drvinf
 	}
 
 	dump_mac(regs->data);
-	dump_gmac("GMAC 1", regs->data + 0x2800);
-	dump_gmac_fifo(regs->data + 0xc40);
 
 	printf("\nStatus BMU:\n-----------\n");
 	printf("Control                                0x%08X\n",
@@ -350,6 +349,14 @@ int sky2_dump_regs(struct ethtool_drvinf
 	dump_timer("TX status", regs->data + 0xec0);
 	dump_timer("ISR", regs->data + 0xed0);
 
+	printf("\nGMAC control             0x%04X\n", *(u32 *)(regs->data + 0xf00));
+	printf("GPHY control             0x%04X\n", *(u32 *)(regs->data + 0xf04));
+	printf("LINK control             0x%02hX\n", *(u16 *)(regs->data + 0xf10));
+
+	dump_gmac("GMAC 1", regs->data + 0x2800);
+	dump_gmac_fifo("Rx GMAC 1", regs->data + 0xc40);
+	dump_gmac_fifo("Tx GMAC 1", regs->data + 0xd40);
+
 	dump_queue2("Receive Queue 1", regs->data +0x400, 1);
 	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue2("Async Transmit Queue 1", regs->data +0x680, 0);
@@ -364,7 +371,8 @@ int sky2_dump_regs(struct ethtool_drvinf
 		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
 		dump_gmac("GMAC 2", regs->data + 0x3800);
-		dump_gmac_fifo(regs->data + 0xc40 + 128);
+		dump_gmac_fifo("Rx GMAC 2", regs->data + 0xc40 + 128);
+		dump_gmac_fifo("Tx GMAC 2", regs->data + 0xd40 + 128);
 	}
 
 	return 0;
-- 
1.4.1

