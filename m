From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] ethtool: sky2 GMAC decode
Date: Wed, 18 Oct 2006 10:46:32 -0700
Message-ID: <20061018104632.27a37d75@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36582 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161257AbWJRSJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 14:09:02 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add decoding of GMAC bits.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/marvell.c b/marvell.c
index 16147a9..244bb69 100644
--- a/marvell.c
+++ b/marvell.c
@@ -113,6 +113,31 @@ static void dump_fifo(const char *name, 
 	dump_timer("LED", p + 0x20);
 }
 
+static void dump_gmac_fifo(const void *p)
+{
+	const u32 *r = p;
+	int i;
+	static const char *regs[] = {
+		"End Address",
+		"Almost Full Thresh",
+		"Control/Test",
+		"FIFO Flush Mask",
+		"FIFO Flush Threshold",
+		"Truncation Threshold",
+		"Upper Pause Threshold",
+		"Lower Pause Threshold",
+		"VLAN Tag",
+		"FIFO Write Pointer",
+		"FIFO Write Level",
+		"FIFO Read Pointer",
+		"FIFO Read Level",
+	};
+
+	for (i = 0; i < sizeof(regs)/sizeof(regs[0]); ++i)
+		printf("%-32s 0x%08X\n", regs[i], r[i]);
+
+}
+
 static void dump_mac(const u8 *r)
 {
 	printf("\nMAC Addresses\n");
@@ -143,6 +168,7 @@ static void dump_gma(const char *name, c
 static void dump_gmac(const char *name, const u8 *data)
 {
 	printf("\n%s\n", name);
+
 	printf("Status                       0x%04X\n", *(u16 *) data);
 	printf("Control                      0x%04X\n", *(u16 *) (data + 4));
 	printf("Transmit                     0x%04X\n", *(u16 *) (data + 8));
@@ -294,6 +320,7 @@ int sky2_dump_regs(struct ethtool_drvinf
 
 	dump_mac(regs->data);
 	dump_gmac("GMAC 1", regs->data + 0x2800);
+	dump_gmac_fifo(regs->data + 0xc40);
 
 	printf("\nStatus BMU:\n-----------\n");
 	printf("Control                                0x%08X\n",
@@ -337,6 +364,7 @@ int sky2_dump_regs(struct ethtool_drvinf
 		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
 		dump_gmac("GMAC 2", regs->data + 0x3800);
+		dump_gmac_fifo(regs->data + 0xc40 + 128);
 	}
 
 	return 0;
-- 
1.4.1

