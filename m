From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/5] netiucv: change name of nop function
Date: Fri, 08 Feb 2008 13:09:03 +0100
Message-ID: <20080208121513.827935000@linux.vnet.ibm.com>
References: <20080208120900.295604000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:31307 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759602AbYBHMPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 07:15:16 -0500
Content-Disposition: inline; filename=753-netiucv-fsm.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Dummy NOP actions for fsm-statemachines have to be defined
separately for every using module of fsm-statemachines.
Thus the generic name fsm_action_nop is replaced by
module specific name netiucv_action_nop.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/netiucv.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/netiucv.c
+++ linux-2.6-uschi/drivers/s390/net/netiucv.c
@@ -573,9 +573,9 @@ static void netiucv_callback_connres(str
 }
 
 /**
- * Dummy NOP action for all statemachines
+ * NOP action for statemachines
  */
-static void fsm_action_nop(fsm_instance *fi, int event, void *arg)
+static void netiucv_action_nop(fsm_instance *fi, int event, void *arg)
 {
 }
 
@@ -1111,7 +1111,7 @@ static const fsm_node dev_fsm[] = {
 
 	{ DEV_STATE_RUNNING,    DEV_EVENT_STOP,    dev_action_stop     },
 	{ DEV_STATE_RUNNING,    DEV_EVENT_CONDOWN, dev_action_conndown },
-	{ DEV_STATE_RUNNING,    DEV_EVENT_CONUP,   fsm_action_nop      },
+	{ DEV_STATE_RUNNING,    DEV_EVENT_CONUP,   netiucv_action_nop  },
 };
 
 static const int DEV_FSM_LEN = sizeof(dev_fsm) / sizeof(fsm_node);

-- 
