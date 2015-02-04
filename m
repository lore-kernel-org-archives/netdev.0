From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 1/3] drivers: isdn: isdnloop: isdnloop.c: remove assignment of variables in if conditions, in accordance with the CodingStyle.
Date: Wed,  4 Feb 2015 23:32:59 +0100
Message-ID: <1423089181-15850-2-git-send-email-baspeters93@gmail.com>
References: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/isdnloop/isdnloop.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index 5a4da94..af96317 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -59,7 +59,8 @@ isdnloop_bchan_send(isdnloop_card *card, int ch)
 	isdn_ctrl cmd;
 
 	while (card->sndcount[ch]) {
-		if ((skb = skb_dequeue(&card->bqueue[ch]))) {
+		skb = skb_dequeue(&card->bqueue[ch]);
+		if (skb) {
 			len = skb->len;
 			card->sndcount[ch] -= len;
 			ack = *(skb->head); /* used as scratch area */
@@ -317,7 +318,8 @@ isdnloop_polldchan(unsigned long data)
 	u_char *p;
 	isdn_ctrl cmd;
 
-	if ((skb = skb_dequeue(&card->dqueue)))
+	skb = skb_dequeue(&card->dqueue);
+	if (skb)
 		avail = skb->len;
 	else
 		avail = 0;
@@ -471,8 +473,8 @@ isdnloop_fake(isdnloop_card *card, char *s, int ch)
 {
 	struct sk_buff *skb;
 	int len = strlen(s) + ((ch >= 0) ? 3 : 0);
-
-	if (!(skb = dev_alloc_skb(len))) {
+	skb = dev_alloc_skb(len);
+	if (!skb) {
 		printk(KERN_WARNING "isdnloop: Out of memory in isdnloop_fake\n");
 		return 1;
 	}
@@ -1439,8 +1441,8 @@ isdnloop_initcard(char *id)
 {
 	isdnloop_card *card;
 	int i;
-
-	if (!(card = kzalloc(sizeof(isdnloop_card), GFP_KERNEL))) {
+	card = kzalloc(sizeof(isdnloop_card), GFP_KERNEL);
+	if (!card) {
 		printk(KERN_WARNING
 		       "isdnloop: (%s) Could not allocate card-struct.\n", id);
 		return (isdnloop_card *) 0;
@@ -1489,8 +1491,8 @@ static int
 isdnloop_addcard(char *id1)
 {
 	isdnloop_card *card;
-
-	if (!(card = isdnloop_initcard(id1))) {
+	card = isdnloop_initcard(id1);
+	if (!card) {
 		return -EIO;
 	}
 	printk(KERN_INFO
-- 
2.1.0
