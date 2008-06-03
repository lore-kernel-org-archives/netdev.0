From: Mark Asselstine <mark.asselstine@windriver.com>
Subject: [PATCH] Cleanup use of deprecated calls to save_and_cli and restore_flags.
Date: Tue,  3 Jun 2008 12:19:19 -0400
Message-ID: <1212509959-8763-1-git-send-email-mark.asselstine@windriver.com>
Cc: mark.asselstine@windriver.com
To: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39559 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751380AbYFCQTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 12:19:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of local_irq_save and local_irq_restore rather then the
deprecated save_and_cli and restore_flags calls.

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
---
 drivers/net/sunhme.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index b4e7f30..1aa425b 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -111,7 +111,7 @@ static __inline__ void tx_add_log(struct happy_meal *hp, unsigned int a, unsigne
 	struct hme_tx_logent *tlp;
 	unsigned long flags;
 
-	save_and_cli(flags);
+	local_irq_save(flags);
 	tlp = &tx_log[txlog_cur_entry];
 	tlp->tstamp = (unsigned int)jiffies;
 	tlp->tx_new = hp->tx_new;
@@ -119,7 +119,7 @@ static __inline__ void tx_add_log(struct happy_meal *hp, unsigned int a, unsigne
 	tlp->action = a;
 	tlp->status = s;
 	txlog_cur_entry = (txlog_cur_entry + 1) & (TX_LOG_LEN - 1);
-	restore_flags(flags);
+	local_irq_restore(flags);
 }
 static __inline__ void tx_dump_log(void)
 {
-- 
1.5.4.3

