From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 20/20] net: remove [un]register_pernet_gen_... and update the docs.
Date: Sun, 29 Nov 2009 17:46:17 -0800
Message-ID: <1259545577-7466-20-git-send-email-ebiederm@xmission.com>
References: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Cc: <netdev@vger.kernel.org>, jamal <hadi@cyberus.ca>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46479 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319AbZK3Bqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:46:34 -0500
In-Reply-To: <1259545577-7466-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

No that all of the callers have been updated to set fields in
struct pernet_operations, and simplified to let the network
namespace core handle the allocation and freeing of the storage
for them, remove the surpurpflous methods and update the docs
to the new style.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |   22 ----------------------
 include/net/netns/generic.h |    8 +++++---
 2 files changed, 5 insertions(+), 25 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 080774b..24a8c55 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -264,28 +264,6 @@ extern void unregister_pernet_subsys(struct pernet_operations *);
 extern int register_pernet_device(struct pernet_operations *);
 extern void unregister_pernet_device(struct pernet_operations *);
 
-static inline int register_pernet_gen_subsys(int *id, struct pernet_operations *ops)
-{
-	ops->id = id;
-	return register_pernet_subsys(ops);
-}
-
-static inline void unregister_pernet_gen_subsys(int id, struct pernet_operations *ops)
-{
-	return unregister_pernet_subsys(ops);
-}
-
-static inline int register_pernet_gen_device(int *id, struct pernet_operations *ops)
-{
-	ops->id = id;
-	return register_pernet_device(ops);
-}
-
-static inline void unregister_pernet_gen_device(int id, struct pernet_operations *ops)
-{
-	return unregister_pernet_device(ops);
-}
-
 struct ctl_path;
 struct ctl_table;
 struct ctl_table_header;
diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
index 0c04fd2..ff4982a 100644
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -12,9 +12,11 @@
  * stuff on the struct net without explicit struct net modification
  *
  * The rules are simple:
- * 1. register the ops with register_pernet_gen_device to get the id
- *    of your private pointer;
- * 2. call net_assign_generic() to put the private data on the struct
+ * 1. set pernet_operations->id.  After register_pernet_device you
+ *    will have the id of your private pointer.
+ * 2. Either set pernet_operations->size (to have the code allocate and
+ *    free a private structure pointed to from struct net ) or 
+ *    call net_assign_generic() to put the private data on the struct
  *    net (most preferably this should be done in the ->init callback
  *    of the ops registered);
  * 3. do not change this pointer while the net is alive;
-- 
1.6.5.2.143.g8cc62

