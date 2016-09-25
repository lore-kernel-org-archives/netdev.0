From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] ISDN-CAPI: Delete error messages for a failed memory
 allocation in four functions
Date: Sun, 25 Sep 2016 13:12:28 +0200
Message-ID: <3baf0b5c-4687-0ac7-6bf5-5cf7129e3c03@users.sourceforge.net>
References: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Wolfram Sang <wsa@the-dreams.de>
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <be07f84d-fc84-e47d-207e-aedd8c960151@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 25 Sep 2016 11:17:39 +0200

Omit an extra message for a memory allocation failure in a few functions.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/capi/capidrv.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index cd8e1a6..bb945dd 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -471,7 +471,6 @@ static int capidrv_add_ack(struct capidrv_ncci *nccip,
 
 	n = kmalloc(sizeof(struct ncci_datahandle_queue), GFP_ATOMIC);
 	if (!n) {
-		printk(KERN_ERR "capidrv: kmalloc ncci_datahandle failed\n");
 		return -1;
 	}
 	n->next = NULL;
@@ -513,7 +512,6 @@ static void send_message(capidrv_contr *card, _cmsg *cmsg)
 	len = CAPIMSG_LEN(cmsg->buf);
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_ERR "capidrv::send_message: can't allocate mem\n");
 		return;
 	}
 	memcpy(skb_put(skb, len), cmsg->buf, len);
@@ -2111,8 +2109,6 @@ static int if_sendbuf(int id, int channel, int doack, struct sk_buff *skb)
 	if (skb_headroom(skb) < msglen) {
 		struct sk_buff *nskb = skb_realloc_headroom(skb, msglen);
 		if (!nskb) {
-			printk(KERN_ERR "capidrv-%d: if_sendbuf: no memory\n",
-			       card->contrnr);
 			(void)capidrv_del_ack(nccip, datahandle);
 			return 0;
 		}
@@ -2259,8 +2255,6 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 		return -1;
 	}
 	if (!(card = kzalloc(sizeof(capidrv_contr), GFP_ATOMIC))) {
-		printk(KERN_WARNING
-		       "capidrv: (%s) Could not allocate contr-struct.\n", id);
 		return -1;
 	}
 	card->owner = THIS_MODULE;
@@ -2272,8 +2266,6 @@ static int capidrv_addcontr(u16 contr, struct capi_profile *profp)
 				     sizeof(capidrv_bchan),
 				     GFP_ATOMIC);
 	if (!card->bchans) {
-		printk(KERN_WARNING
-		       "capidrv: (%s) Could not allocate bchan-structs.\n", id);
 		module_put(card->owner);
 		kfree(card);
 		return -1;
-- 
2.10.0
