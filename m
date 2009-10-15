From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 3/5] [PATCH] lcs: ODEBUG: object is on stack, but not annotated.
Date: Thu, 15 Oct 2009 10:54:57 +0200
Message-ID: <20091015090749.766278000@linux.vnet.ibm.com>
References: <20091015085454.124154000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Klaus-Dieter Wacker <kdwacker@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:38923 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756306AbZJOJI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 05:08:28 -0400
Content-Disposition: inline; filename=610-lcs-odebug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-Dieter Wacker <kdwacker@de.ibm.com>

Timer_list structure in lcs_send_lancmd() is allocated on stack. 
Initialization with init_timer() leads to above ODEBUG message.
Instead use init_timer_on_stack() which prevents above msg.

Signed-off-by: Klaus-Dieter Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2009-10-15 10:19:32.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2009-10-15 10:19:51.000000000 +0200
@@ -889,7 +889,7 @@ lcs_send_lancmd(struct lcs_card *card, s
 	rc = lcs_ready_buffer(&card->write, buffer);
 	if (rc)
 		return rc;
-	init_timer(&timer);
+	init_timer_on_stack(&timer);
 	timer.function = lcs_lancmd_timeout;
 	timer.data = (unsigned long) reply;
 	timer.expires = jiffies + HZ*card->lancmd_timeout;

