From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] ISDN-CAPI: Delete unnecessary braces
Date: Sun, 25 Sep 2016 13:15:09 +0200
Message-ID: <06e7637c-f682-bfa2-82b6-47d071bd58c4@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 12:50:21 +0200

Do not use curly brackets at eight source code places
where a single statement should be sufficient.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/capi/capidrv.c | 30 +++++++++++-------------------
 1 file changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 83f756d..7f58644 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -470,9 +470,8 @@ static int capidrv_add_ack(struct capidrv_ncci *nccip,
 	struct ncci_datahandle_queue *n, **pp;
 
 	n = kmalloc(sizeof(struct ncci_datahandle_queue), GFP_ATOMIC);
-	if (!n) {
+	if (!n)
 		return -1;
-	}
 	n->next = NULL;
 	n->datahandle = datahandle;
 	n->len = len;
@@ -511,9 +510,8 @@ static void send_message(capidrv_contr *card, _cmsg *cmsg)
 	}
 	len = CAPIMSG_LEN(cmsg->buf);
 	skb = alloc_skb(len, GFP_ATOMIC);
-	if (!skb) {
+	if (!skb)
 		return;
-	}
 	memcpy(skb_put(skb, len), cmsg->buf, len);
 	if (capi20_put_message(&global.ap, skb) != CAPI_NOERROR)
 		kfree_skb(skb);
@@ -976,13 +974,12 @@ static void handle_controller(_cmsg *cmsg)
 		if (debugmode)
 			printk(KERN_DEBUG "capidrv-%d: listenconf Info=0x%4x (%s) cipmask=0x%x\n",
 			       card->contrnr, cmsg->Info, capi_info2str(cmsg->Info), card->cipmask);
-		if (cmsg->Info) {
+		if (cmsg->Info)
 			listen_change_state(card, EV_LISTEN_CONF_ERROR);
-		} else if (card->cipmask == 0) {
+		else if (card->cipmask == 0)
 			listen_change_state(card, EV_LISTEN_CONF_EMPTY);
-		} else {
+		     else
 			listen_change_state(card, EV_LISTEN_CONF_OK);
-		}
 		break;
 
 	case CAPI_MANUFACTURER_IND:	/* Controller */
@@ -1263,11 +1260,10 @@ static void handle_plci(_cmsg *cmsg)
 			goto notfound;
 
 		plcip->plci = cmsg->adr.adrPLCI;
-		if (cmsg->Info) {
+		if (cmsg->Info)
 			plci_change_state(card, plcip, EV_PLCI_CONNECT_CONF_ERROR);
-		} else {
+		else
 			plci_change_state(card, plcip, EV_PLCI_CONNECT_CONF_OK);
-		}
 		break;
 
 	case CAPI_CONNECT_ACTIVE_IND:	/* plci */
@@ -1476,10 +1472,9 @@ static void handle_ncci(_cmsg *cmsg)
 		goto ignored;
 
 	case CAPI_DATA_B3_CONF:	/* ncci */
-		if (cmsg->Info) {
+		if (cmsg->Info)
 			printk(KERN_WARNING "CAPI_DATA_B3_CONF: Info %x - %s\n",
 			       cmsg->Info, capi_info2str(cmsg->Info));
-		}
 		nccip = find_ncci(card, cmsg->adr.adrNCCI);
 		if (!nccip)
 			goto notfound;
@@ -2319,9 +2314,8 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 	}
 	card->myid = card->interface.channels;
 	memset(card->bchans, 0, sizeof(capidrv_bchan) * card->nbchan);
-	for (i = 0; i < card->nbchan; i++) {
+	for (i = 0; i < card->nbchan; i++)
 		card->bchans[i].contr = card;
-	}
 
 	spin_lock_irqsave(&global_lock, flags);
 	card->next = global.contr_list;
@@ -2354,10 +2348,9 @@ static int capidrv_delcontr(u16 contr)
 	isdn_ctrl cmd;
 
 	spin_lock_irqsave(&global_lock, flags);
-	for (card = global.contr_list; card; card = card->next) {
+	for (card = global.contr_list; card; card = card->next)
 		if (card->contrnr == contr)
 			break;
-	}
 	if (!card) {
 		spin_unlock_irqrestore(&global_lock, flags);
 		printk(KERN_ERR "capidrv: delcontr: no contr %u\n", contr);
@@ -2504,9 +2497,8 @@ static int __init capidrv_init(void)
 
 	global.ap.recv_message = capidrv_recv_message;
 	errcode = capi20_register(&global.ap);
-	if (errcode) {
+	if (errcode)
 		return -EIO;
-	}
 
 	register_capictr_notifier(&capictr_nb);
 
-- 
2.10.0
