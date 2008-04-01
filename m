From: frank.blaschka@de.ibm.com
Subject: [patch 8/8] qeth: keep ip-address after LAN_OFFLINE failure
Date: Tue, 01 Apr 2008 10:27:00 +0200
Message-ID: <20080401082745.841399000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <braunu@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:8045 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654AbYDAI1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:48 -0400
Content-Disposition: inline; filename=08-qeth_lan_offline.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <braunu@de.ibm.com>

Problem:     If setting of an ip-address fails with LAN_OFFLINE,
             qeth does not save the ip-address in its internal
             list of set ip-addresses. qeth recovers after a
             following STARTLAN event, but cannot set the unsaved
             ip-address.
Solution:    save the ip-address in the qeth-maintained list of
             ip-addresses after a LAN_OFFLINE failure for SETIP.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l3_main.c	2008-03-31 13:21:04.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c	2008-03-31 13:21:41.000000000 +0200
@@ -461,7 +461,7 @@
 			spin_unlock_irqrestore(&card->ip_lock, flags);
 			rc = qeth_l3_register_addr_entry(card, todo);
 			spin_lock_irqsave(&card->ip_lock, flags);
-			if (!rc)
+			if (!rc || (rc == IPA_RC_LAN_OFFLINE))
 				list_add_tail(&todo->entry, &card->ip_list);
 			else
 				kfree(todo);

-- 
