From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: ematch: module autoloading
Date: Wed, 11 Jul 2007 20:01:32 +0200
Message-ID: <46951AFC.60500@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010908090708040606050405"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58801 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbXGKSBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010908090708040606050405
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------010908090708040606050405
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: ematch: module autoloading

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit daa5d0f76104559af6718688e0e37ff9fda9ea6a
tree 78efa14a3dda378a4b9dbc88ff5e1108671a4028
parent 5ff8523dfdac610944d1f85f54e30cd96dc6104b
author Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:59:26 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:59:26 +0200

 include/linux/pkt_cls.h |   17 +++++++----------
 include/net/pkt_cls.h   |    2 ++
 net/sched/em_cmp.c      |    1 +
 net/sched/em_meta.c     |    2 ++
 net/sched/em_nbyte.c    |    2 ++
 net/sched/em_text.c     |    2 ++
 net/sched/em_u32.c      |    2 ++
 net/sched/ematch.c      |   13 +++++++++++++
 8 files changed, 31 insertions(+), 10 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index c3f01b3..30b8571 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -403,16 +403,13 @@ enum
  *   1..32767		Reserved for ematches inside kernel tree
  *   32768..65535	Free to use, not reliable
  */
-enum
-{
-	TCF_EM_CONTAINER,
-	TCF_EM_CMP,
-	TCF_EM_NBYTE,
-	TCF_EM_U32,
-	TCF_EM_META,
-	TCF_EM_TEXT,
-	__TCF_EM_MAX
-};
+#define	TCF_EM_CONTAINER	0
+#define	TCF_EM_CMP		1
+#define	TCF_EM_NBYTE		2
+#define	TCF_EM_U32		3
+#define	TCF_EM_META		4
+#define	TCF_EM_TEXT		5
+#define	TCF_EM_MAX		5
 
 enum
 {
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 4129df7..6c29920 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -306,6 +306,8 @@ static inline int tcf_em_tree_match(struct sk_buff *skb,
 		return 1;
 }
 
+#define MODULE_ALIAS_TCF_EMATCH(kind)	MODULE_ALIAS("ematch-kind-" __stringify(kind))
+
 #else /* CONFIG_NET_EMATCH */
 
 struct tcf_ematch_tree
diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index 8d6dacd..cc49c93 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -98,3 +98,4 @@ MODULE_LICENSE("GPL");
 module_init(init_em_cmp);
 module_exit(exit_em_cmp);
 
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_CMP);
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 60acf8c..650f09c 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -848,3 +848,5 @@ MODULE_LICENSE("GPL");
 
 module_init(init_em_meta);
 module_exit(exit_em_meta);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_META);
diff --git a/net/sched/em_nbyte.c b/net/sched/em_nbyte.c
index b4b36ef..370a1b2 100644
--- a/net/sched/em_nbyte.c
+++ b/net/sched/em_nbyte.c
@@ -76,3 +76,5 @@ MODULE_LICENSE("GPL");
 
 module_init(init_em_nbyte);
 module_exit(exit_em_nbyte);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_NBYTE);
diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index e8f4616..d5cd86e 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -150,3 +150,5 @@ MODULE_LICENSE("GPL");
 
 module_init(init_em_text);
 module_exit(exit_em_text);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_TEXT);
diff --git a/net/sched/em_u32.c b/net/sched/em_u32.c
index 0a2a7fe..112796e 100644
--- a/net/sched/em_u32.c
+++ b/net/sched/em_u32.c
@@ -60,3 +60,5 @@ MODULE_LICENSE("GPL");
 
 module_init(init_em_u32);
 module_exit(exit_em_u32);
+
+MODULE_ALIAS_TCF_EMATCH(TCF_EM_U32);
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index 2483739..f3a104e 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -222,6 +222,19 @@ static int tcf_em_validate(struct tcf_proto *tp,
 
 		if (em->ops == NULL) {
 			err = -ENOENT;
+#ifdef CONFIG_KMOD
+			__rtnl_unlock();
+			request_module("ematch-kind-%u", em_hdr->kind);
+			rtnl_lock();
+			em->ops = tcf_em_lookup(em_hdr->kind);
+			if (em->ops) {
+				/* We dropped the RTNL mutex in order to
+				 * perform the module load. Tell the caller
+				 * to replay the request. */
+				module_put(em->ops->owner);
+				err = -EAGAIN;
+			}
+#endif
 			goto errout;
 		}
 

--------------010908090708040606050405--
