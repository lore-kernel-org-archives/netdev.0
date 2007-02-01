From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH ethtool] marvell chip decode formatting
Date: Wed, 31 Jan 2007 16:23:46 -0800
Message-ID: <20070131162346.48d796d4@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60970 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933381AbXBAA0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 19:26:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix some typo's and formatting on Marvell ethtool output.
If sync transmit queue is not used, don't print settings.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 marvell.c |   37 ++++++++++++++++++++++++-------------
 1 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/marvell.c b/marvell.c
index b73addc..b17548e 100644
--- a/marvell.c
+++ b/marvell.c
@@ -51,6 +51,12 @@ static void dump_queue(const char *name,
 	};
 	const struct desc *d = a;
 
+	/* is reset bit set? */
+	if (!(d->ctl & 2)) {
+		printf("\n%s (disabled)\n", name);
+		return;
+	}
+
 	printf("\n%s\n", name);
 	printf("---------------\n");
 	printf("Descriptor Address       0x%08X%08X\n",
@@ -82,13 +88,19 @@ static void dump_ram(const char *name, c
 {
 	const u32 *r = p;
 
+	if (!(r[10] & 2)) {
+		printf("\n%s (disabled)\n", name);
+		return;
+	}
+
 	printf("\n%s\n", name);
 	printf("---------------\n");
 	printf("Start Address                    0x%08X\n", r[0]);
 	printf("End Address                      0x%08X\n", r[1]);
 	printf("Write Pointer                    0x%08X\n", r[2]);
 	printf("Read Pointer                     0x%08X\n", r[3]);
-	if (*name == 'R') {
+
+	if (*name == 'R') { /* Receive only */
 		printf("Upper Threshold/Pause Packets    0x%08X\n", r[4]);
 		printf("Lower Threshold/Pause Packets    0x%08X\n", r[5]);
 		printf("Upper Threshold/High Priority    0x%08X\n", r[6]);
@@ -96,7 +108,7 @@ static void dump_ram(const char *name, c
 	}
 	printf("Packet Counter                   0x%08X\n", r[8]);
 	printf("Level                            0x%08X\n", r[9]);
-	printf("Test                             0x%08X\n", r[10]);
+	printf("Control                          0x%08X\n", r[10]);
 }
 
 static void dump_fifo(const char *name, const void *p)
@@ -161,15 +173,14 @@ static void dump_mac(const u8 *r)
 	id = r[0x11b];
 	printf("Chip Id                      0x%02X ", id);
 	switch (id) {
-	case 0x0a:	puts("Genesis");	break;
-	case 0xb0:	puts("Yukon");	break;
-	case 0xb1:	puts("Yukon-Lite");	break;
-	case 0xb2:	puts("Yukon-LP");	break;
-	case 0xb3:	puts("Yukon-2 XL");	break;
-	case 0xb4:	puts("Yukon-2 EC Ultra");	break;
-	case 0xb6:	puts("Yukon-2 EC");	break;
- 	case 0xb7:	puts("Yukon-2 FE");	break;
-	default:	puts("Unknown");
+	case 0x0a:	printf("Genesis");	break;
+	case 0xb0:	printf("Yukon");	break;
+	case 0xb1:	printf("Yukon-Lite");	break;
+	case 0xb2:	printf("Yukon-LP");	break;
+	case 0xb3:	printf("Yukon-2 XL");	break;
+	case 0xb4:	printf("Yukon-2 EC Ultra");	break;
+	case 0xb6:	printf("Yukon-2 EC");	break;
+ 	case 0xb7:	printf("Yukon-2 FE");	break;
 	}
 
 	printf(" (rev %d)\n", r[0x11a] & 0xf);
@@ -328,9 +339,9 @@ static void dump_queue2(const char *name
 	printf("Request                          0x%08X%08X\n",
 	       d->req_hi, d->req_lo);
 	if (rx) {
-		printf("Csum1      Offset %4d Piston   %d\n",
+		printf("Csum1      Offset %4d Position   %d\n",
 		       d->csum1, d->csum1_start);
-		printf("Csum2      Offset %4d Positing   %d\n",
+		printf("Csum2      Offset %4d Position  %d\n",
 		       d->csum2, d->csum2_start);
 	} else
 		printf("Csum Start 0x%04X Pos %4d Write %d\n",
-- 
1.4.1

