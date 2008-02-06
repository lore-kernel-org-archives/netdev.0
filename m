From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/4] ctc / netiucv: consolidate fsm_action_nop
Date: Wed, 06 Feb 2008 19:27:24 +0100
Message-ID: <20080206183021.700790000@linux.vnet.ibm.com>
References: <20080206182723.103842000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:58418 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbYBFSaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 13:30:25 -0500
Content-Disposition: inline; filename=700-fsm.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

move fsm_action_nop to fsm.h to avoid duplicate definitions in
both drivers ctc and netiucv.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>

---
 drivers/s390/net/ctcmain.c |    8 --------
 drivers/s390/net/fsm.h     |    8 ++++++++
 drivers/s390/net/netiucv.c |    8 +-------
 3 files changed, 9 insertions(+), 15 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/fsm.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/fsm.h
+++ linux-2.6-uschi/drivers/s390/net/fsm.h
@@ -260,4 +260,12 @@ extern int fsm_addtimer(fsm_timer *timer
  */
 extern void fsm_modtimer(fsm_timer *timer, int millisec, int event, void *arg);
 
+/**
+ * NOP action for statemachines
+ */
+static inline void
+fsm_action_nop(fsm_instance *fi, int event, void *arg)
+{
+}
+
 #endif /* _FSM_H_ */
Index: linux-2.6-uschi/drivers/s390/net/netiucv.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/netiucv.c
+++ linux-2.6-uschi/drivers/s390/net/netiucv.c
@@ -137,6 +137,7 @@ PRINT_##importance(header "%02x %02x %02
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 static struct device_driver netiucv_driver = {
+	.owner = THIS_MODULE,
 	.name = "netiucv",
 	.bus  = &iucv_bus,
 };
@@ -571,13 +572,6 @@ static void netiucv_callback_connres(str
 	fsm_event(conn->fsm, CONN_EVENT_CONN_RES, conn);
 }
 
-/**
- * Dummy NOP action for all statemachines
- */
-static void fsm_action_nop(fsm_instance *fi, int event, void *arg)
-{
-}
-
 /*
  * Actions of the connection statemachine
  */
Index: linux-2.6-uschi/drivers/s390/net/ctcmain.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcmain.c
+++ linux-2.6-uschi/drivers/s390/net/ctcmain.c
@@ -644,14 +644,6 @@ ctc_checkalloc_buffer(struct channel *ch
 }
 
 /**
- * Dummy NOP action for statemachines
- */
-static void
-fsm_action_nop(fsm_instance * fi, int event, void *arg)
-{
-}
-
-/**
  * Actions for channel - statemachines.
  *****************************************************************************/
 

-- 
