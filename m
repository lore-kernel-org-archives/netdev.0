From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a
	compound statement
Date: Mon, 22 Dec 2008 20:15:07 +0100
Message-ID: <20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755177AbYLVTPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:15:14 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While at it insert some extra curly braces and fix formatting.

Fix this sparse warnings:

  drivers/net/atp.c:811:8: warning: do-while statement is not a compound statement
  drivers/net/atp.c:813:8: warning: do-while statement is not a compound statement
  drivers/net/atp.c:815:11: warning: do-while statement is not a compound statement
  drivers/net/atp.c:817:11: warning: do-while statement is not a compound statement
  drivers/net/plip.c:642:4: warning: do-while statement is not a compound statement
  drivers/net/plip.c:647:4: warning: do-while statement is not a compound statement
  drivers/net/plip.c:820:4: warning: do-while statement is not a compound statement
  drivers/net/plip.c:825:4: warning: do-while statement is not a compound statement
  drivers/net/starfire.c:886:3: warning: do-while statement is not a compound statement

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/atp.c      |   19 ++++++++++---------
 drivers/net/plip.c     |   16 ++++++++--------
 drivers/net/starfire.c |    4 ++--
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 1d6b74c..ea493ce 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -802,21 +802,22 @@ static void net_rx(struct net_device *dev)
 
 static void read_block(long ioaddr, int length, unsigned char *p, int data_mode)
 {
-
 	if (data_mode <= 3) { /* Mode 0 or 1 */
 		outb(Ctrl_LNibRead, ioaddr + PAR_CONTROL);
 		outb(length == 8  ?  RdAddr | HNib | MAR  :  RdAddr | MAR,
 			 ioaddr + PAR_DATA);
 		if (data_mode <= 1) { /* Mode 0 or 1 */
-			do  *p++ = read_byte_mode0(ioaddr);  while (--length > 0);
-		} else	/* Mode 2 or 3 */
-			do  *p++ = read_byte_mode2(ioaddr);  while (--length > 0);
-	} else if (data_mode <= 5)
-		do      *p++ = read_byte_mode4(ioaddr);  while (--length > 0);
-	else
-		do      *p++ = read_byte_mode6(ioaddr);  while (--length > 0);
+			do { *p++ = read_byte_mode0(ioaddr); } while (--length > 0);
+		} else { /* Mode 2 or 3 */
+			do { *p++ = read_byte_mode2(ioaddr); } while (--length > 0);
+		}
+	} else if (data_mode <= 5) {
+		do { *p++ = read_byte_mode4(ioaddr); } while (--length > 0);
+	} else {
+		do { *p++ = read_byte_mode6(ioaddr); } while (--length > 0);
+	}
 
-    outb(EOC+HNib+MAR, ioaddr + PAR_DATA);
+	outb(EOC+HNib+MAR, ioaddr + PAR_DATA);
 	outb(Ctrl_SelData, ioaddr + PAR_CONTROL);
 }
 
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 5d904f7..ed8582e 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -638,14 +638,14 @@ plip_receive_packet(struct net_device *dev, struct net_local *nl,
 
 	case PLIP_PK_DATA:
 		lbuf = rcv->skb->data;
-		do
+		do {
 			if (plip_receive(nibble_timeout, dev,
 					 &rcv->nibble, &lbuf[rcv->byte]))
 				return TIMEOUT;
-		while (++rcv->byte < rcv->length.h);
-		do
+		} while (++rcv->byte < rcv->length.h);
+		do {
 			rcv->checksum += lbuf[--rcv->byte];
-		while (rcv->byte);
+		} while (rcv->byte);
 		rcv->state = PLIP_PK_CHECKSUM;
 
 	case PLIP_PK_CHECKSUM:
@@ -816,14 +816,14 @@ plip_send_packet(struct net_device *dev, struct net_local *nl,
 		snd->checksum = 0;
 
 	case PLIP_PK_DATA:
-		do
+		do {
 			if (plip_send(nibble_timeout, dev,
 				      &snd->nibble, lbuf[snd->byte]))
 				return TIMEOUT;
-		while (++snd->byte < snd->length.h);
-		do
+		} while (++snd->byte < snd->length.h);
+		do {
 			snd->checksum += lbuf[--snd->byte];
-		while (snd->byte);
+		} while (snd->byte);
 		snd->state = PLIP_PK_CHECKSUM;
 
 	case PLIP_PK_CHECKSUM:
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 01493a4..8bfc15b 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -882,9 +882,9 @@ static int mdio_read(struct net_device *dev, int phy_id, int location)
 	void __iomem *mdio_addr = np->base + MIICtrl + (phy_id<<7) + (location<<2);
 	int result, boguscnt=1000;
 	/* ??? Should we add a busy-wait here? */
-	do
+	do {
 		result = readl(mdio_addr);
-	while ((result & 0xC0000000) != 0x80000000 && --boguscnt > 0);
+	} while ((result & 0xC0000000) != 0x80000000 && --boguscnt > 0);
 	if (boguscnt == 0)
 		return 0;
 	if ((result & 0xffff) == 0xffff)

