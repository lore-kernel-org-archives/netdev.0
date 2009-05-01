From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC] isdn: rename capi_ctr_reseted() to capi_ctr_down()
Date: Fri, 1 May 2009 12:44:55 +0200
Message-ID: <20090501130517.A2F4E11181E@xenon.ts.pxnet.com>
To: isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:56979 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753232AbZEANF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 09:05:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kernel CAPI exported function capi_ctr_reseted() is named rather
irritatingly IMHO. I'd like to propose renaming it to something that
represents better what that function is actually about, as per the
following patch.

Opinions? Objections?

Thanks,
Tilman

isdn: rename capi_ctr_reseted() to capi_ctr_down()

Change the function name to something representing its purpose better.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/INTERFACE.CAPI |    4 ++--
 drivers/isdn/capi/kcapi.c         |    8 ++++----
 drivers/isdn/hardware/avm/b1.c    |    2 +-
 drivers/isdn/hardware/avm/b1dma.c |    2 +-
 drivers/isdn/hardware/avm/c4.c    |    4 ++--
 drivers/isdn/hardware/avm/t1isa.c |    2 +-
 drivers/isdn/hysdn/hycapi.c       |    4 ++--
 include/linux/isdn/capilli.h      |    2 +-
 net/bluetooth/cmtp/capi.c         |    2 +-
 9 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/Documentation/isdn/INTERFACE.CAPI b/Documentation/isdn/INTERFACE.CAPI
index 786d619..4631538 100644
--- a/Documentation/isdn/INTERFACE.CAPI
+++ b/Documentation/isdn/INTERFACE.CAPI
@@ -45,7 +45,7 @@ From then on, Kernel CAPI may call the registered callback functions for the
 device.
 
 If the device becomes unusable for any reason (shutdown, disconnect ...), the
-driver has to call capi_ctr_reseted(). This will prevent further calls to the
+driver has to call capi_ctr_down(). This will prevent further calls to the
 callback functions by Kernel CAPI.
 
 
@@ -166,7 +166,7 @@ int detach_capi_ctr(struct capi_ctr *ctrlr)
 	register/unregister a device (controller) with Kernel CAPI
 
 void capi_ctr_ready(struct capi_ctr *ctrlr)
-void capi_ctr_reseted(struct capi_ctr *ctrlr)
+void capi_ctr_down(struct capi_ctr *ctrlr)
 	signal controller ready/not ready
 
 void capi_ctr_suspend_output(struct capi_ctr *ctrlr)
diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index f331703..57d2636 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -377,14 +377,14 @@ void capi_ctr_ready(struct capi_ctr * card)
 EXPORT_SYMBOL(capi_ctr_ready);
 
 /**
- * capi_ctr_reseted() - signal CAPI controller reset
+ * capi_ctr_down() - signal CAPI controller not ready
  * @card:	controller descriptor structure.
  *
  * Called by hardware driver to signal that the controller is down and
  * unavailable for use.
  */
 
-void capi_ctr_reseted(struct capi_ctr * card)
+void capi_ctr_down(struct capi_ctr * card)
 {
 	u16 appl;
 
@@ -413,7 +413,7 @@ void capi_ctr_reseted(struct capi_ctr * card)
 	notify_push(KCI_CONTRDOWN, card->cnr, 0, 0);
 }
 
-EXPORT_SYMBOL(capi_ctr_reseted);
+EXPORT_SYMBOL(capi_ctr_down);
 
 /**
  * capi_ctr_suspend_output() - suspend controller
@@ -517,7 +517,7 @@ EXPORT_SYMBOL(attach_capi_ctr);
 int detach_capi_ctr(struct capi_ctr *card)
 {
         if (card->cardstate != CARD_DETECTED)
-		capi_ctr_reseted(card);
+		capi_ctr_down(card);
 
 	ncards--;
 
diff --git a/drivers/isdn/hardware/avm/b1.c b/drivers/isdn/hardware/avm/b1.c
index abf05ec..a7c0083 100644
--- a/drivers/isdn/hardware/avm/b1.c
+++ b/drivers/isdn/hardware/avm/b1.c
@@ -330,7 +330,7 @@ void b1_reset_ctr(struct capi_ctr *ctrl)
 	spin_lock_irqsave(&card->lock, flags);
 	capilib_release(&cinfo->ncci_head);
 	spin_unlock_irqrestore(&card->lock, flags);
-	capi_ctr_reseted(ctrl);
+	capi_ctr_down(ctrl);
 }
 
 void b1_register_appl(struct capi_ctr *ctrl,
diff --git a/drivers/isdn/hardware/avm/b1dma.c b/drivers/isdn/hardware/avm/b1dma.c
index da34b98..0e84aaa 100644
--- a/drivers/isdn/hardware/avm/b1dma.c
+++ b/drivers/isdn/hardware/avm/b1dma.c
@@ -759,7 +759,7 @@ void b1dma_reset_ctr(struct capi_ctr *ctrl)
 	memset(cinfo->version, 0, sizeof(cinfo->version));
 	capilib_release(&cinfo->ncci_head);
 	spin_unlock_irqrestore(&card->lock, flags);
-	capi_ctr_reseted(ctrl);
+	capi_ctr_down(ctrl);
 }
 
 /* ------------------------------------------------------------- */
diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 9df1d3f..6833301 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -681,7 +681,7 @@ static irqreturn_t c4_handle_interrupt(avmcard *card)
 			spin_lock_irqsave(&card->lock, flags);
 			capilib_release(&cinfo->ncci_head);
 			spin_unlock_irqrestore(&card->lock, flags);
-			capi_ctr_reseted(&cinfo->capi_ctrl);
+			capi_ctr_down(&cinfo->capi_ctrl);
 		}
 		card->nlogcontr = 0;
 		return IRQ_HANDLED;
@@ -909,7 +909,7 @@ static void c4_reset_ctr(struct capi_ctr *ctrl)
         for (i=0; i < card->nr_controllers; i++) {
 		cinfo = &card->ctrlinfo[i];
 		memset(cinfo->version, 0, sizeof(cinfo->version));
-		capi_ctr_reseted(&cinfo->capi_ctrl);
+		capi_ctr_down(&cinfo->capi_ctrl);
 	}
 	card->nlogcontr = 0;
 }
diff --git a/drivers/isdn/hardware/avm/t1isa.c b/drivers/isdn/hardware/avm/t1isa.c
index e772449..1c53fd4 100644
--- a/drivers/isdn/hardware/avm/t1isa.c
+++ b/drivers/isdn/hardware/avm/t1isa.c
@@ -339,7 +339,7 @@ static void t1isa_reset_ctr(struct capi_ctr *ctrl)
 	spin_lock_irqsave(&card->lock, flags);
 	capilib_release(&cinfo->ncci_head);
 	spin_unlock_irqrestore(&card->lock, flags);
-	capi_ctr_reseted(ctrl);
+	capi_ctr_down(ctrl);
 }
 
 static void t1isa_remove(struct pci_dev *pdev)
diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 53f6ad1..4ffaa14 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -67,7 +67,7 @@ hycapi_reset_ctr(struct capi_ctr *ctrl)
 	printk(KERN_NOTICE "HYCAPI hycapi_reset_ctr\n");
 #endif
 	capilib_release(&cinfo->ncci_head);
-	capi_ctr_reseted(ctrl);
+	capi_ctr_down(ctrl);
 }
 
 /******************************
@@ -347,7 +347,7 @@ int hycapi_capi_stop(hysdn_card *card)
 	if(cinfo) {
 		ctrl = &cinfo->capi_ctrl;
 /*		ctrl->suspend_output(ctrl); */
-		capi_ctr_reseted(ctrl);
+		capi_ctr_down(ctrl);
 	}
 	return 0;
 }
diff --git a/include/linux/isdn/capilli.h b/include/linux/isdn/capilli.h
index 35e9b0f..7acb87a 100644
--- a/include/linux/isdn/capilli.h
+++ b/include/linux/isdn/capilli.h
@@ -79,7 +79,7 @@ int attach_capi_ctr(struct capi_ctr *);
 int detach_capi_ctr(struct capi_ctr *);
 
 void capi_ctr_ready(struct capi_ctr * card);
-void capi_ctr_reseted(struct capi_ctr * card);
+void capi_ctr_down(struct capi_ctr * card);
 void capi_ctr_suspend_output(struct capi_ctr * card);
 void capi_ctr_resume_output(struct capi_ctr * card);
 void capi_ctr_handle_message(struct capi_ctr * card, u16 appl, struct sk_buff *skb);
diff --git a/net/bluetooth/cmtp/capi.c b/net/bluetooth/cmtp/capi.c
index 78958c0..97f8d68 100644
--- a/net/bluetooth/cmtp/capi.c
+++ b/net/bluetooth/cmtp/capi.c
@@ -382,7 +382,7 @@ static void cmtp_reset_ctr(struct capi_ctr *ctrl)
 
 	BT_DBG("ctrl %p", ctrl);
 
-	capi_ctr_reseted(ctrl);
+	capi_ctr_down(ctrl);
 
 	atomic_inc(&session->terminate);
 	cmtp_schedule(session);
-- 
1.6.2.1.214.ge986c

