From: frank.blaschka@de.ibm.com
Subject: [patch 3/8] qeth: set lan_online flag after a received STARTLAN
Date: Tue, 01 Apr 2008 10:26:55 +0200
Message-ID: <20080401082742.159757000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:4277 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbYDAI1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:44 -0400
Content-Disposition: inline; filename=03-qeth_startlan.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Problem:     A STARTLAN command from the adapter may arrive while a
             qeth recovery is currently running with a failed qeth
             STARTLAN. Usually qeth schedules a recovery when
             receiving a STARTLAN command from the adapter. But
             another recovery scheduled while a recovery is already
             running never starts. Thus the qeth-administered
             lan_online flag remains zero in this scenario, even
             though the adapter-STARTLAN has happened.
Solution:    Set lan_online flag for a received STARTLAN from the
             adapter in case scheduled recovery does not start.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    1 +
 1 file changed, 1 insertion(+)

Index: git_davem-2.6.26/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_main.c	2008-03-31 11:17:33.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_main.c	2008-03-31 11:18:50.000000000 +0200
@@ -417,6 +417,7 @@
 					   QETH_CARD_IFNAME(card),
 					   card->info.chpid);
 				netif_carrier_on(card->dev);
+				card->lan_online = 1;
 				qeth_schedule_recovery(card);
 				return NULL;
 			case IPA_CMD_MODCCID:

-- 
