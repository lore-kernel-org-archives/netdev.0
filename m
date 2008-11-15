From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ematch: simpler tcf_em_unregister()
Date: Sun, 16 Nov 2008 01:55:01 +0300
Message-ID: <20081115225501.GA2189@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:10705 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbYKOWv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 17:51:28 -0500
Received: by ug-out-1314.google.com with SMTP id 39so158301ugf.37
        for <netdev@vger.kernel.org>; Sat, 15 Nov 2008 14:51:27 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply delete ops from list and let list debugging do the job.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/pkt_cls.h |    2 +-
 net/sched/ematch.c    |   18 +++---------------
 2 files changed, 4 insertions(+), 16 deletions(-)

--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -246,7 +246,7 @@ struct tcf_ematch_ops
 };
 
 extern int tcf_em_register(struct tcf_ematch_ops *);
-extern int tcf_em_unregister(struct tcf_ematch_ops *);
+extern void tcf_em_unregister(struct tcf_ematch_ops *);
 extern int tcf_em_tree_validate(struct tcf_proto *, struct nlattr *,
 				struct tcf_ematch_tree *);
 extern void tcf_em_tree_destroy(struct tcf_proto *, struct tcf_ematch_tree *);
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -71,7 +71,7 @@
  *
  *      static void __exit exit_my_ematch(void)
  *      {
- *      	return tcf_em_unregister(&my_ops);
+ *      	tcf_em_unregister(&my_ops);
  *      }
  *
  *      module_init(init_my_ematch);
@@ -154,23 +154,11 @@ EXPORT_SYMBOL(tcf_em_register);
  *
  * Returns -ENOENT if no matching ematch was found.
  */
-int tcf_em_unregister(struct tcf_ematch_ops *ops)
+void tcf_em_unregister(struct tcf_ematch_ops *ops)
 {
-	int err = 0;
-	struct tcf_ematch_ops *e;
-
 	write_lock(&ematch_mod_lock);
-	list_for_each_entry(e, &ematch_ops, link) {
-		if (e == ops) {
-			list_del(&e->link);
-			goto out;
-		}
-	}
-
-	err = -ENOENT;
-out:
+	list_del(&ops->link);
 	write_unlock(&ematch_mod_lock);
-	return err;
 }
 EXPORT_SYMBOL(tcf_em_unregister);
 
