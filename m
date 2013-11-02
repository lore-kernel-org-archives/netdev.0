From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 08/13] driver: isdn: remove unnecessary NULL check before dev_kfree_skb_any
Date: Sat,  2 Nov 2013 19:17:49 +0530
Message-ID: <1383400074-30555-9-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_kfree_skb_any is protected from NULL. No need to check for NULL
while calling this function.

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/isdn/gigaset/ser-gigaset.c | 3 +--
 drivers/isdn/hisax/hfc_usb.c       | 6 ++----
 drivers/isdn/hisax/icc.c           | 6 ++----
 drivers/isdn/hisax/ipacx.c         | 6 ++----
 drivers/isdn/hisax/isac.c          | 6 ++----
 drivers/isdn/hisax/st5481_b.c      | 6 ++----
 drivers/isdn/hisax/w6692.c         | 6 ++----
 7 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 8c91fd5..9128526 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -221,8 +221,7 @@ static void flush_send_queue(struct cardstate *cs)
 	spin_unlock_irqrestore(&cs->cmdlock, flags);
 
 	/* data queue */
-	if (cs->bcs->tx_skb)
-		dev_kfree_skb_any(cs->bcs->tx_skb);
+	dev_kfree_skb_any(cs->bcs->tx_skb);
 	while ((skb = skb_dequeue(&cs->bcs->squeue)) != NULL)
 		dev_kfree_skb_any(skb);
 }
diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index 849a807..a1f8380 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -864,10 +864,8 @@ rx_int_complete(struct urb *urb)
 		    fifon, urb->status);
 
 		fifo->urb->interval = 0;	/* cancel automatic rescheduling */
-		if (fifo->skbuff) {
-			dev_kfree_skb_any(fifo->skbuff);
-			fifo->skbuff = NULL;
-		}
+		dev_kfree_skb_any(fifo->skbuff);
+		fifo->skbuff = NULL;
 		return;
 	}
 	len = urb->actual_length;
diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 51dae91..2c52996 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -549,10 +549,8 @@ ICC_l1hw(struct PStack *st, int pr, void *arg)
 	case (HW_DEACTIVATE | RESPONSE):
 		skb_queue_purge(&cs->rq);
 		skb_queue_purge(&cs->sq);
-		if (cs->tx_skb) {
-			dev_kfree_skb_any(cs->tx_skb);
-			cs->tx_skb = NULL;
-		}
+		dev_kfree_skb_any(cs->tx_skb);
+		cs->tx_skb = NULL;
 		if (test_and_clear_bit(FLG_DBUSY_TIMER, &cs->HW_Flags))
 			del_timer(&cs->dbusytimer);
 		if (test_and_clear_bit(FLG_L1_DBUSY, &cs->HW_Flags))
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 5faa5de..55192a4 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -181,10 +181,8 @@ dch_l2l1(struct PStack *st, int pr, void *arg)
 	case (HW_DEACTIVATE | RESPONSE):
 		skb_queue_purge(&cs->rq);
 		skb_queue_purge(&cs->sq);
-		if (cs->tx_skb) {
-			dev_kfree_skb_any(cs->tx_skb);
-			cs->tx_skb = NULL;
-		}
+		dev_kfree_skb_any(cs->tx_skb);
+		cs->tx_skb = NULL;
 		if (test_and_clear_bit(FLG_DBUSY_TIMER, &cs->HW_Flags))
 			del_timer(&cs->dbusytimer);
 		break;
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index 7fdf78f..d0895f2 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -547,10 +547,8 @@ ISAC_l1hw(struct PStack *st, int pr, void *arg)
 	case (HW_DEACTIVATE | RESPONSE):
 		skb_queue_purge(&cs->rq);
 		skb_queue_purge(&cs->sq);
-		if (cs->tx_skb) {
-			dev_kfree_skb_any(cs->tx_skb);
-			cs->tx_skb = NULL;
-		}
+		dev_kfree_skb_any(cs->tx_skb);
+		cs->tx_skb = NULL;
 		if (test_and_clear_bit(FLG_DBUSY_TIMER, &cs->HW_Flags))
 			del_timer(&cs->dbusytimer);
 		if (test_and_clear_bit(FLG_L1_DBUSY, &cs->HW_Flags))
diff --git a/drivers/isdn/hisax/st5481_b.c b/drivers/isdn/hisax/st5481_b.c
index 4098491..b753aca 100644
--- a/drivers/isdn/hisax/st5481_b.c
+++ b/drivers/isdn/hisax/st5481_b.c
@@ -254,10 +254,8 @@ static void st5481B_mode(struct st5481_bcs *bcs, int mode)
 		} else {
 			st5481_usb_device_ctrl_msg(adapter, GPIO_OUT, adapter->leds, NULL, NULL);
 		}
-		if (b_out->tx_skb) {
-			dev_kfree_skb_any(b_out->tx_skb);
-			b_out->tx_skb = NULL;
-		}
+		dev_kfree_skb_any(b_out->tx_skb);
+		b_out->tx_skb = NULL;
 
 	}
 }
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index a858955..dd1fbf4 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -653,10 +653,8 @@ W6692_l1hw(struct PStack *st, int pr, void *arg)
 	case (HW_DEACTIVATE | RESPONSE):
 		skb_queue_purge(&cs->rq);
 		skb_queue_purge(&cs->sq);
-		if (cs->tx_skb) {
-			dev_kfree_skb_any(cs->tx_skb);
-			cs->tx_skb = NULL;
-		}
+		dev_kfree_skb_any(cs->tx_skb);
+		cs->tx_skb = NULL;
 		if (test_and_clear_bit(FLG_DBUSY_TIMER, &cs->HW_Flags))
 			del_timer(&cs->dbusytimer);
 		if (test_and_clear_bit(FLG_L1_DBUSY, &cs->HW_Flags))
-- 
1.8.4.2
