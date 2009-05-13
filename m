From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/8] gigaset: remove obsolete references to m10x state table
Date: Thu, 14 May 2009 00:44:17 +0200 (CEST)
Message-ID: <20090514-patch-05.tilman@imap.cc>
References: <20090514-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:38979 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757919AbZEMWoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 18:44:34 -0400
In-Reply-To: <20090514-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The separation of state tables for base and M10x has long been
removed. Clean up remaining traces of it.

Impact: cleanup
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/common.c   |   10 ++--------
 drivers/isdn/gigaset/ev-layer.c |    4 ++--
 drivers/isdn/gigaset/gigaset.h  |    4 ++--
 3 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 0048ce9..79c9b0f 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -672,14 +672,8 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->tty = NULL;
 	cs->tty_dev = NULL;
 	cs->cidmode = cidmode != 0;
-
-	//if(onechannel) { //FIXME
-		cs->tabnocid = gigaset_tab_nocid_m10x;
-		cs->tabcid = gigaset_tab_cid_m10x;
-	//} else {
-	//	cs->tabnocid = gigaset_tab_nocid;
-	//	cs->tabcid = gigaset_tab_cid;
-	//}
+	cs->tabnocid = gigaset_tab_nocid;
+	cs->tabcid = gigaset_tab_cid;
 
 	init_waitqueue_head(&cs->waitqueue);
 	cs->waiting = 0;
diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index e582a48..ec51696 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -160,7 +160,7 @@
 
 
 // 100: init, 200: dle0, 250:dle1, 300: get cid (dial), 350: "hup" (no cid), 400: hup, 500: reset, 600: dial, 700: ring
-struct reply_t gigaset_tab_nocid_m10x[]= /* with dle mode */
+struct reply_t gigaset_tab_nocid[] =
 {
 	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
 
@@ -280,7 +280,7 @@ struct reply_t gigaset_tab_nocid_m10x[]= /* with dle mode */
 };
 
 // 600: start dialing, 650: dial in progress, 800: connection is up, 700: ring, 400: hup, 750: accepted icall
-struct reply_t gigaset_tab_cid_m10x[] = /* for M10x */
+struct reply_t gigaset_tab_cid[] =
 {
 	/* resp_code, min_ConState, max_ConState, parameter, new_ConState, timeout, action, command */
 
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 747178f..d5f0110 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -282,8 +282,8 @@ struct reply_t {
 	char	*command;	/* NULL==none */
 };
 
-extern struct reply_t gigaset_tab_cid_m10x[];
-extern struct reply_t gigaset_tab_nocid_m10x[];
+extern struct reply_t gigaset_tab_cid[];
+extern struct reply_t gigaset_tab_nocid[];
 
 struct inbuf_t {
 	unsigned char		*rcvbuf;	/* usb-gigaset receive buffer */
-- 
1.6.2.1.214.ge986c

