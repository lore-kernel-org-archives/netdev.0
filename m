From: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
Subject: [PATCH] Drivers: isdn: hisax: isac.c: Fix assignment and check into one expression.
Date: Sat, 26 Mar 2016 02:49:50 +0200
Message-ID: <1458953390-7306-1-git-send-email-gabrielcsmo@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix variable assignment inside if statement. It is error-prone and hard to read.

Signed-off-by: Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>
---
 drivers/isdn/hisax/isac.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 7fdf78f..df7e05c 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -215,9 +215,11 @@ isac_interrupt(struct IsdnCardState *cs, u_char val)
 			if (count == 0)
 				count = 32;
 			isac_empty_fifo(cs, count);
-			if ((count = cs->rcvidx) > 0) {
+			count = cs->rcvidx;
+			if (count > 0) {
 				cs->rcvidx = 0;
-				if (!(skb = alloc_skb(count, GFP_ATOMIC)))
+				skb = alloc_skb(count, GFP_ATOMIC);
+				if (!skb)
 					printk(KERN_WARNING "HiSax: D receive out of memory\n");
 				else {
 					memcpy(skb_put(skb, count), cs->rcvbuf, count);
@@ -251,7 +253,8 @@ isac_interrupt(struct IsdnCardState *cs, u_char val)
 				cs->tx_skb = NULL;
 			}
 		}
-		if ((cs->tx_skb = skb_dequeue(&cs->sq))) {
+		cs->tx_skb = skb_dequeue(&cs->sq);
+		if (cs->tx_skb) {
 			cs->tx_cnt = 0;
 			isac_fill_fifo(cs);
 		} else
@@ -313,7 +316,8 @@ afterXPR:
 #if ARCOFI_USE
 			if (v1 & 0x08) {
 				if (!cs->dc.isac.mon_rx) {
-					if (!(cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC))) {
+					cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC);
+					if (!cs->dc.isac.mon_rx) {
 						if (cs->debug & L1_DEB_WARN)
 							debugl1(cs, "ISAC MON RX out of memory!");
 						cs->dc.isac.mocr &= 0xf0;
@@ -343,7 +347,8 @@ afterXPR:
 		afterMONR0:
 			if (v1 & 0x80) {
 				if (!cs->dc.isac.mon_rx) {
-					if (!(cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC))) {
+					cs->dc.isac.mon_rx = kmalloc(MAX_MON_FRAME, GFP_ATOMIC);
+					if (!cs->dc.isac.mon_rx) {
 						if (cs->debug & L1_DEB_WARN)
 							debugl1(cs, "ISAC MON RX out of memory!");
 						cs->dc.isac.mocr &= 0x0f;
-- 
1.9.1
