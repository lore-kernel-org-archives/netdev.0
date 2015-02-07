From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 3/7] drivers: isdn: act2000: remove assignments of variables in if conditions
Date: Sat,  7 Feb 2015 20:05:25 +0100
Message-ID: <1423335929-24926-4-git-send-email-baspeters93@gmail.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes all assignments of if conditions, which is not in
accordance with the CodingStyle.
---
 drivers/isdn/act2000/module.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index c3a1b06..352916a 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -289,7 +289,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 			if (copy_from_user(tmp, arg,
 					   sizeof(tmp)))
 				return -EFAULT;
-			if ((ret = act2000_set_msn(card, tmp)))
+			ret = act2000_set_msn(card, tmp);
+			if (ret)
 				return ret;
 			if (card->flags & ACT2000_FLAGS_RUNNING)
 				return (actcapi_manufacturer_req_msn(card));
@@ -312,7 +313,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_DIAL:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		spin_lock_irqsave(&card->lock, flags);
 		if (chan->fsm_state != ACT2000_STATE_NULL) {
@@ -341,7 +343,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_ACCEPTD:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		if (chan->fsm_state == ACT2000_STATE_ICALL)
 			actcapi_select_b2_protocol_req(card, chan);
@@ -353,7 +356,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_HANGUP:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		switch (chan->fsm_state) {
 		case ACT2000_STATE_ICALL:
@@ -368,7 +372,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_SETEAZ:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		if (strlen(c->parm.num)) {
 			if (card->ptype == ISDN_PTYPE_EURO) {
@@ -388,7 +393,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_CLREAZ:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		chan->eazmask = 0;
 		actcapi_listen_req(card);
@@ -396,7 +402,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 	case ISDN_CMD_SETL2:
 		if (!(card->flags & ACT2000_FLAGS_RUNNING))
 			return -ENODEV;
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		chan->l2prot = (c->arg >> 8);
 		return 0;
@@ -407,7 +414,8 @@ act2000_command(act2000_card *card, isdn_ctrl *c)
 			printk(KERN_WARNING "L3 protocol unknown\n");
 			return -1;
 		}
-		if (!(chan = find_channel(card, c->arg & 0x0f)))
+		chan = find_channel(card, c->arg & 0x0f);
+		if (!chan)
 			break;
 		chan->l3prot = (c->arg >> 8);
 		return 0;
@@ -424,7 +432,8 @@ act2000_sendbuf(act2000_card *card, int channel, int ack, struct sk_buff *skb)
 	act2000_chan *chan;
 	actcapi_msg *msg;
 
-	if (!(chan = find_channel(card, channel)))
+	chan = find_channel(card, channel);
+	if (!chan)
 		return -1;
 	if (chan->fsm_state != ACT2000_STATE_ACTIVE)
 		return -1;
@@ -573,7 +582,8 @@ act2000_alloccard(int bus, int port, int irq, char *id)
 {
 	int i;
 	act2000_card *card;
-	if (!(card = kzalloc(sizeof(act2000_card), GFP_KERNEL))) {
+	card = kzalloc(sizeof(act2000_card), GFP_KERNEL);
+	if (!card) {
 		printk(KERN_WARNING
 		       "act2000: (%s) Could not allocate card-struct.\n", id);
 		return;
-- 
2.1.0
