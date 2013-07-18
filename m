From: Alexandru Juncu <alexj@rosedu.org>
Subject: [PATCH] mISDN: replace sum of bitmasks with OR operation.
Date: Thu, 18 Jul 2013 14:36:48 +0300
Message-ID: <1374147408-14890-1-git-send-email-alexj@rosedu.org>
Cc: standby24x7@gmail.com, davem@davemloft.net,
	gregkh@linuxfoundation.org, jkosina@suse.cz,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandru Juncu <alexj@rosedu.org>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggested by coccinelle and manually verified.

Signed-off-by: Alexandru Juncu <alexj@rosedu.org>
---
 drivers/isdn/hardware/mISDN/hfcpci.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index a7e4939..7f910c7 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1307,11 +1307,11 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 		}
 		if (fifo2 & 2) {
 			hc->hw.fifo_en &= ~HFCPCI_FIFOEN_B2;
-			hc->hw.int_m1 &= ~(HFCPCI_INTS_B2TRANS +
+			hc->hw.int_m1 &= ~(HFCPCI_INTS_B2TRANS |
 					   HFCPCI_INTS_B2REC);
 		} else {
 			hc->hw.fifo_en &= ~HFCPCI_FIFOEN_B1;
-			hc->hw.int_m1 &= ~(HFCPCI_INTS_B1TRANS +
+			hc->hw.int_m1 &= ~(HFCPCI_INTS_B1TRANS |
 					   HFCPCI_INTS_B1REC);
 		}
 #ifdef REVERSE_BITORDER
@@ -1346,14 +1346,14 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 		if (fifo2 & 2) {
 			hc->hw.fifo_en |= HFCPCI_FIFOEN_B2;
 			if (!tics)
-				hc->hw.int_m1 |= (HFCPCI_INTS_B2TRANS +
+				hc->hw.int_m1 |= (HFCPCI_INTS_B2TRANS |
 						  HFCPCI_INTS_B2REC);
 			hc->hw.ctmt |= 2;
 			hc->hw.conn &= ~0x18;
 		} else {
 			hc->hw.fifo_en |= HFCPCI_FIFOEN_B1;
 			if (!tics)
-				hc->hw.int_m1 |= (HFCPCI_INTS_B1TRANS +
+				hc->hw.int_m1 |= (HFCPCI_INTS_B1TRANS |
 						  HFCPCI_INTS_B1REC);
 			hc->hw.ctmt |= 1;
 			hc->hw.conn &= ~0x03;
@@ -1375,14 +1375,14 @@ mode_hfcpci(struct bchannel *bch, int bc, int protocol)
 		if (fifo2 & 2) {
 			hc->hw.last_bfifo_cnt[1] = 0;
 			hc->hw.fifo_en |= HFCPCI_FIFOEN_B2;
-			hc->hw.int_m1 |= (HFCPCI_INTS_B2TRANS +
+			hc->hw.int_m1 |= (HFCPCI_INTS_B2TRANS |
 					  HFCPCI_INTS_B2REC);
 			hc->hw.ctmt &= ~2;
 			hc->hw.conn &= ~0x18;
 		} else {
 			hc->hw.last_bfifo_cnt[0] = 0;
 			hc->hw.fifo_en |= HFCPCI_FIFOEN_B1;
-			hc->hw.int_m1 |= (HFCPCI_INTS_B1TRANS +
+			hc->hw.int_m1 |= (HFCPCI_INTS_B1TRANS |
 					  HFCPCI_INTS_B1REC);
 			hc->hw.ctmt &= ~1;
 			hc->hw.conn &= ~0x03;
-- 
1.8.1.2
