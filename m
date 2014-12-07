From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 5/20] isdn: fix misspelling of current function in string
Date: Sun,  7 Dec 2014 20:20:47 +0100
Message-ID: <1417980062-25151-6-git-send-email-Julia.Lawall@lip6.fr>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux@rasmusvillemoes.dk,
	joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a misspelled function name by %s and then __func__.

In the first case, the print is just dropped, because kmalloc itself does
enough error reporting.

This was done using Coccinelle, including the use of Levenshtein distance,
as proposed by Rasmus Villemoes.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch is difficult to summarize, but is available in the cover
letter of this patch series.

 drivers/isdn/hisax/hfc_2bs0.c |    2 +-
 drivers/isdn/hisax/hfc_sx.c   |    3 ++-
 drivers/isdn/hisax/hfc_usb.c  |    5 ++---
 drivers/isdn/hisax/ipacx.c    |    2 +-
 drivers/isdn/hisax/isdnl1.c   |    2 +-
 drivers/isdn/hisax/isdnl3.c   |    2 +-
 drivers/isdn/hysdn/hycapi.c   |    2 +-
 drivers/isdn/pcbit/layer2.c   |    1 -
 8 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/pcbit/layer2.c b/drivers/isdn/pcbit/layer2.c
index 42ecfef..46e1240 100644
--- a/drivers/isdn/pcbit/layer2.c
+++ b/drivers/isdn/pcbit/layer2.c
@@ -85,7 +85,6 @@ pcbit_l2_write(struct pcbit_dev *dev, ulong msg, ushort refnum,
 	}
 	if ((frame = kmalloc(sizeof(struct frame_buf),
 			     GFP_ATOMIC)) == NULL) {
-		printk(KERN_WARNING "pcbit_2_write: kmalloc failed\n");
 		dev_kfree_skb(skb);
 		return -1;
 	}
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 5faa5de..9cc26b4 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -580,7 +580,7 @@ bch_fill_fifo(struct BCState *bcs)
 	if (cs->debug & L1_DEB_HSCX_FIFO) {
 		char *t = bcs->blog;
 
-		t += sprintf(t, "chb_fill_fifo() B-%d cnt %d", hscx, count);
+		t += sprintf(t, "%s() B-%d cnt %d", __func__, hscx, count);
 		QuickHex(t, ptr, count);
 		debugl1(cs, "%s", bcs->blog);
 	}
diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index 849a807..678bd52 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -927,9 +927,8 @@ start_int_fifo(usb_fifo *fifo)
 	fifo->active = 1;	/* must be marked active */
 	errcode = usb_submit_urb(fifo->urb, GFP_KERNEL);
 	if (errcode) {
-		printk(KERN_ERR
-		       "HFC-S USB: submit URB error(start_int_info): status:%i\n",
-		       errcode);
+		printk(KERN_ERR "HFC-S USB: submit URB error(%s): status:%i\n",
+		       __func__, errcode);
 		fifo->active = 0;
 		fifo->skbuff = NULL;
 	}
diff --git a/drivers/isdn/hisax/hfc_2bs0.c b/drivers/isdn/hisax/hfc_2bs0.c
index 838531b..14dada4 100644
--- a/drivers/isdn/hisax/hfc_2bs0.c
+++ b/drivers/isdn/hisax/hfc_2bs0.c
@@ -31,7 +31,7 @@ WaitForBusy(struct IsdnCardState *cs)
 		to--;
 	}
 	if (!to) {
-		printk(KERN_WARNING "HiSax: waitforBusy timeout\n");
+		printk(KERN_WARNING "HiSax: %s timeout\n", __func__);
 		return (0);
 	} else
 		return (to);
diff --git a/drivers/isdn/hisax/isdnl1.c b/drivers/isdn/hisax/isdnl1.c
index 8000957..a560842 100644
--- a/drivers/isdn/hisax/isdnl1.c
+++ b/drivers/isdn/hisax/isdnl1.c
@@ -867,7 +867,7 @@ l1_msg(struct IsdnCardState *cs, int pr, void *arg) {
 			break;
 		default:
 			if (cs->debug)
-				debugl1(cs, "l1msg %04X unhandled", pr);
+				debugl1(cs, "%s %04X unhandled", __func__, pr);
 			break;
 		}
 		st = st->next;
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index fa1fefd..b1fad81 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1159,7 +1159,8 @@ hfcsx_l2l1(struct PStack *st, int pr, void *arg)
 	case (PH_PULL | INDICATION):
 		spin_lock_irqsave(&bcs->cs->lock, flags);
 		if (bcs->tx_skb) {
-			printk(KERN_WARNING "hfc_l2l1: this shouldn't happen\n");
+			printk(KERN_WARNING "%s: this shouldn't happen\n",
+			       __func__);
 		} else {
 //				test_and_set_bit(BC_FLG_BUSY, &bcs->Flag);
 			bcs->tx_skb = skb;
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
index 45b0384..c754706 100644
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -153,7 +153,7 @@ void
 newl3state(struct l3_process *pc, int state)
 {
 	if (pc->debug & L3_DEB_STATE)
-		l3_debug(pc->st, "newstate cr %d %d --> %d",
+		l3_debug(pc->st, "%s cr %d %d --> %d", __func__,
 			 pc->callref & 0x7F,
 			 pc->state, state);
 	pc->state = state;
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 00aad10..93bae94 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -501,7 +501,7 @@ static char *hycapi_procinfo(struct capi_ctr *ctrl)
 {
 	hycapictrl_info *cinfo = (hycapictrl_info *)(ctrl->driverdata);
 #ifdef HYCAPI_PRINTFNAMES
-	printk(KERN_NOTICE "hycapi_proc_info\n");
+	printk(KERN_NOTICE "%s\n", __func__);
 #endif
 	if (!cinfo)
 		return "";

