From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 1/6] drivers: isdn: act2000: act2000_isa.c: Fix checkpatch errors
Date: Sat,  7 Feb 2015 18:06:32 +0100
Message-ID: <1423328797-17865-2-git-send-email-baspeters93@gmail.com>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adresses various checkpatch errors:
	3 assignments in if conditions
	1 return value enclosed in parenthesis

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/act2000/act2000_isa.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/act2000/act2000_isa.c b/drivers/isdn/act2000/act2000_isa.c
index b5fad29..048507e 100644
--- a/drivers/isdn/act2000/act2000_isa.c
+++ b/drivers/isdn/act2000/act2000_isa.c
@@ -31,7 +31,8 @@ act2000_isa_reset(unsigned short portbase)
 	int serial = 0;
 
 	found = 0;
-	if ((reg = inb(portbase + ISA_COR)) != 0xff) {
+	reg = inb(portbase + ISA_COR);
+	if (reg != 0xff) {
 		outb(reg | ISA_COR_RESET, portbase + ISA_COR);
 		mdelay(10);
 		outb(reg, portbase + ISA_COR);
@@ -303,7 +304,8 @@ act2000_isa_send(act2000_card *card)
 	while (1) {
 		spin_lock_irqsave(&card->lock, flags);
 		if (!(card->sbuf)) {
-			if ((card->sbuf = skb_dequeue(&card->sndq))) {
+			card->sbuf = skb_dequeue(&card->sndq);
+			if (card->sbuf) {
 				card->ack_msg = card->sbuf->data;
 				msg = (actcapi_msg *)card->sbuf->data;
 				if ((msg->hdr.cmd.cmd == 0x86) &&
@@ -378,7 +380,8 @@ act2000_isa_getid(act2000_card *card)
 		printk(KERN_WARNING "act2000: Wrong Firmware-ID!\n");
 		return -EPROTO;
 	}
-	if ((p = strchr(fid.revision, '\n')))
+	p = strchr(fid.revision, '\n');
+	if (p)
 		*p = '\0';
 	printk(KERN_INFO "act2000: Firmware-ID: %s\n", fid.revision);
 	if (card->flags & ACT2000_FLAGS_IVALID) {
@@ -439,5 +442,5 @@ act2000_isa_download(act2000_card *card, act2000_ddef __user *cb)
 	}
 	kfree(buf);
 	msleep_interruptible(500);
-	return (act2000_isa_getid(card));
+	return act2000_isa_getid(card);
 }
-- 
2.1.0
