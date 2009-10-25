From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 6/9] ser_gigaset: checkpatch cleanup
Date: Sun, 25 Oct 2009 20:30:27 +0100 (CET)
Message-ID: <20091023-patch-gigaset-06.tilman@imap.cc>
References: <20091023-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754116AbZJYTaj@vger.kernel.org>
In-Reply-To: <20091023-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Duly uglified as demanded by checkpatch.pl.

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ser-gigaset.c |   56 +++++++++++++++++++++++------------
 1 files changed, 37 insertions(+), 19 deletions(-)

diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 3071a52..ac3409e 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -164,9 +164,15 @@ static void gigaset_modem_fill(unsigned long data)
 {
 	struct cardstate *cs = (struct cardstate *) data;
 	struct bc_state *bcs;
+	struct sk_buff *nextskb;
 	int sent = 0;
 
-	if (!cs || !(bcs = cs->bcs)) {
+	if (!cs) {
+		gig_dbg(DEBUG_OUTPUT, "%s: no cardstate", __func__);
+		return;
+	}
+	bcs = cs->bcs;
+	if (!bcs) {
 		gig_dbg(DEBUG_OUTPUT, "%s: no cardstate", __func__);
 		return;
 	}
@@ -179,9 +185,11 @@ static void gigaset_modem_fill(unsigned long data)
 			return;
 
 		/* no command to send; get skb */
-		if (!(bcs->tx_skb = skb_dequeue(&bcs->squeue)))
+		nextskb = skb_dequeue(&bcs->squeue);
+		if (!nextskb)
 			/* no skb either, nothing to do */
 			return;
+		bcs->tx_skb = nextskb;
 
 		gig_dbg(DEBUG_INTR, "Dequeued skb (Adr: %lx)",
 			(unsigned long) bcs->tx_skb);
@@ -236,19 +244,20 @@ static void flush_send_queue(struct cardstate *cs)
  *	number of bytes queued, or error code < 0
  */
 static int gigaset_write_cmd(struct cardstate *cs, const unsigned char *buf,
-                             int len, struct tasklet_struct *wake_tasklet)
+			     int len, struct tasklet_struct *wake_tasklet)
 {
 	struct cmdbuf_t *cb;
 	unsigned long flags;
 
 	gigaset_dbg_buffer(cs->mstate != MS_LOCKED ?
-	                     DEBUG_TRANSCMD : DEBUG_LOCKCMD,
-	                   "CMD Transmit", len, buf);
+				DEBUG_TRANSCMD : DEBUG_LOCKCMD,
+			   "CMD Transmit", len, buf);
 
 	if (len <= 0)
 		return 0;
 
-	if (!(cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC))) {
+	cb = kmalloc(sizeof(struct cmdbuf_t) + len, GFP_ATOMIC);
+	if (!cb) {
 		dev_err(cs->dev, "%s: out of memory!\n", __func__);
 		return -ENOMEM;
 	}
@@ -392,7 +401,6 @@ static void gigaset_device_release(struct device *dev)
 	struct platform_device *pdev = to_platform_device(dev);
 
 	/* adapted from platform_device_release() in drivers/base/platform.c */
-	//FIXME is this actually necessary?
 	kfree(dev->platform_data);
 	kfree(pdev->resource);
 }
@@ -404,16 +412,20 @@ static void gigaset_device_release(struct device *dev)
 static int gigaset_initcshw(struct cardstate *cs)
 {
 	int rc;
+	struct ser_cardstate *scs;
 
-	if (!(cs->hw.ser = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL))) {
+	scs = kzalloc(sizeof(struct ser_cardstate), GFP_KERNEL);
+	if (!scs) {
 		pr_err("out of memory\n");
 		return 0;
 	}
+	cs->hw.ser = scs;
 
 	cs->hw.ser->dev.name = GIGASET_MODULENAME;
 	cs->hw.ser->dev.id = cs->minor_index;
 	cs->hw.ser->dev.dev.release = gigaset_device_release;
-	if ((rc = platform_device_register(&cs->hw.ser->dev)) != 0) {
+	rc = platform_device_register(&cs->hw.ser->dev);
+	if (rc != 0) {
 		pr_err("error %d registering platform device\n", rc);
 		kfree(cs->hw.ser);
 		cs->hw.ser = NULL;
@@ -422,7 +434,7 @@ static int gigaset_initcshw(struct cardstate *cs)
 	dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
 
 	tasklet_init(&cs->write_tasklet,
-	             &gigaset_modem_fill, (unsigned long) cs);
+		     &gigaset_modem_fill, (unsigned long) cs);
 	return 1;
 }
 
@@ -434,7 +446,8 @@ static int gigaset_initcshw(struct cardstate *cs)
  * Called by "gigaset_start" and "gigaset_enterconfigmode" in common.c
  * and by "if_lock" and "if_termios" in interface.c
  */
-static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state, unsigned new_state)
+static int gigaset_set_modem_ctrl(struct cardstate *cs, unsigned old_state,
+				  unsigned new_state)
 {
 	struct tty_struct *tty = cs->hw.ser->tty;
 	unsigned int set, clear;
@@ -520,8 +533,8 @@ gigaset_tty_open(struct tty_struct *tty)
 	}
 
 	/* allocate memory for our device state and intialize it */
-	if (!(cs = gigaset_initcs(driver, 1, 1, 0, cidmode,
-				  GIGASET_MODULENAME)))
+	cs = gigaset_initcs(driver, 1, 1, 0, cidmode, GIGASET_MODULENAME);
+	if (!cs)
 		goto error;
 
 	cs->dev = &cs->hw.ser->dev.dev;
@@ -690,7 +703,8 @@ gigaset_tty_receive(struct tty_struct *tty, const unsigned char *buf,
 
 	if (!cs)
 		return;
-	if (!(inbuf = cs->inbuf)) {
+	inbuf = cs->inbuf;
+	if (!inbuf) {
 		dev_err(cs->dev, "%s: no inbuf\n", __func__);
 		cs_put(cs);
 		return;
@@ -770,18 +784,21 @@ static int __init ser_gigaset_init(void)
 	int rc;
 
 	gig_dbg(DEBUG_INIT, "%s", __func__);
-	if ((rc = platform_driver_register(&device_driver)) != 0) {
+	rc = platform_driver_register(&device_driver);
+	if (rc != 0) {
 		pr_err("error %d registering platform driver\n", rc);
 		return rc;
 	}
 
 	/* allocate memory for our driver state and intialize it */
-	if (!(driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
+	driver = gigaset_initdriver(GIGASET_MINOR, GIGASET_MINORS,
 					  GIGASET_MODULENAME, GIGASET_DEVNAME,
-					  &ops, THIS_MODULE)))
+					  &ops, THIS_MODULE);
+	if (!driver)
 		goto error;
 
-	if ((rc = tty_register_ldisc(N_GIGASET_M101, &gigaset_ldisc)) != 0) {
+	rc = tty_register_ldisc(N_GIGASET_M101, &gigaset_ldisc);
+	if (rc != 0) {
 		pr_err("error %d registering line discipline\n", rc);
 		goto error;
 	}
@@ -808,7 +825,8 @@ static void __exit ser_gigaset_exit(void)
 		driver = NULL;
 	}
 
-	if ((rc = tty_unregister_ldisc(N_GIGASET_M101)) != 0)
+	rc = tty_unregister_ldisc(N_GIGASET_M101);
+	if (rc != 0)
 		pr_err("error %d unregistering line discipline\n", rc);
 
 	platform_driver_unregister(&device_driver);
-- 
1.6.2.1.214.ge986c
