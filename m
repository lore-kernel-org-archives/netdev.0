From: Cong Wang <amwang@redhat.com>
Subject: [Patch net] rds: simplify a warning message
Date: Mon,  4 Mar 2013 14:57:18 +0800
Message-ID: <1362380238-10435-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52045 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727Ab3CDG5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 01:57:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>


Cc: David S. Miller <davem@davemloft.net>
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/rds/message.c b/net/rds/message.c
index f0a4658..5586cae 100644
--- a/net/rds/message.c
+++ b/net/rds/message.c
@@ -82,10 +82,7 @@ static void rds_message_purge(struct rds_message *rm)
 void rds_message_put(struct rds_message *rm)
 {
 	rdsdebug("put rm %p ref %d\n", rm, atomic_read(&rm->m_refcount));
-	if (atomic_read(&rm->m_refcount) == 0) {
-printk(KERN_CRIT "danger refcount zero on %p\n", rm);
-WARN_ON(1);
-	}
+	WARN(!atomic_read(&rm->m_refcount), "danger refcount zero on %p\n", rm);
 	if (atomic_dec_and_test(&rm->m_refcount)) {
 		BUG_ON(!list_empty(&rm->m_sock_item));
 		BUG_ON(!list_empty(&rm->m_conn_item));
