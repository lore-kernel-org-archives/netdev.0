From: frank.blaschka@de.ibm.com
Subject: [patch 02/11] netiucv: get rid of in_atomic() use
Date: Thu, 24 Apr 2008 10:15:19 +0200
Message-ID: <20080424081902.526059000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:41682 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbYDXITG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:06 -0400
Content-Disposition: inline; filename=701-netiucv-inatomic.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

There is no urgent need to restart a netiucv connection automatically,
if packets are sent while the netiucv device is not up and running.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/netiucv.c |    2 --
 1 file changed, 2 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/netiucv.c linux-2.6-patched/drivers/s390/net/netiucv.c
--- linux-2.6/drivers/s390/net/netiucv.c	2008-04-23 17:52:28.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/netiucv.c	2008-04-23 17:55:48.000000000 +0200
@@ -1313,8 +1313,6 @@ static int netiucv_tx(struct sk_buff *sk
 	 * and throw away packet.
 	 */
 	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
-		if (!in_atomic())
-			fsm_event(privptr->fsm, DEV_EVENT_START, dev);
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;

-- 
