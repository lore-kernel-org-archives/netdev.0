From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: [PATCH 1/2] [DM9000] Added support for big-endian hosts
Date: Thu, 16 Aug 2007 10:15:35 +0200
Message-ID: <200708161015.35337.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:55698 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760359AbXHPIPh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 04:15:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch splits the receive status in 8bit wide fields and convert th=
e
packet length from little endian to CPU byte order.

Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
---
 drivers/net/dm9000.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index c3de81b..a424810 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -894,7 +894,8 @@ dm9000_timer(unsigned long data)
 }
=20
 struct dm9000_rxhdr {
-	u16	RxStatus;
+	u8	RxPktReady;
+	u8	RxStatus;
 	u16	RxLen;
 } __attribute__((__packed__));
=20
@@ -935,7 +936,7 @@ dm9000_rx(struct net_device *dev)
=20
 		(db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
=20
-		RxLen =3D rxhdr.RxLen;
+		RxLen =3D le16_to_cpu(rxhdr.RxLen);
=20
 		/* Packet Status check */
 		if (RxLen < 0x40) {
@@ -947,17 +948,17 @@ dm9000_rx(struct net_device *dev)
 			PRINTK1("RST: RX Len:%x\n", RxLen);
 		}
=20
-		if (rxhdr.RxStatus & 0xbf00) {
+		if (rxhdr.RxStatus & 0xbf) {
 			GoodPacket =3D false;
-			if (rxhdr.RxStatus & 0x100) {
+			if (rxhdr.RxStatus & 0x01) {
 				PRINTK1("fifo error\n");
 				db->stats.rx_fifo_errors++;
 			}
-			if (rxhdr.RxStatus & 0x200) {
+			if (rxhdr.RxStatus & 0x02) {
 				PRINTK1("crc error\n");
 				db->stats.rx_crc_errors++;
 			}
-			if (rxhdr.RxStatus & 0x8000) {
+			if (rxhdr.RxStatus & 0x80) {
 				PRINTK1("length error\n");
 				db->stats.rx_length_errors++;
 			}
--=20
1.5.0

--=20
Laurent Pinchart
CSE Semaphore Belgium

Chauss=E9e de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75
