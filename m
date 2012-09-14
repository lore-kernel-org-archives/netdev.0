From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v6] cgroup: net_cls: Move sock_update_classid() declaration to cls_cgroup.h
Date: Fri, 14 Sep 2012 16:33:03 +0200
Message-ID: <1347633184-26837-2-git-send-email-wagi@monom.org>
References: <1347633184-26837-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, cgroups@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347633184-26837-1-git-send-email-wagi@monom.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The two users of sock_update_classid() are net/socket.c and
drivers/net/tun.c. socket.c includes cls_cgroup.h already. Update
tun.c to inlcude the header.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Li Zefan <lizefan@huawei.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---

This patch is an updated version of the faulty one. 

 drivers/net/tun.c        | 1 +
 include/net/cls_cgroup.h | 6 ++++++
 include/net/sock.h       | 8 --------
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3a16d4f..9336b82 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -68,6 +68,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
+#include <net/cls_cgroup.h>
 
 #include <asm/uaccess.h>
 
diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..e88527a 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,6 +24,8 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
+extern void sock_update_classid(struct sock *sk);
+
 #ifdef CONFIG_NET_CLS_CGROUP
 static inline u32 task_cls_classid(struct task_struct *p)
 {
@@ -62,6 +64,10 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else
+static inline void sock_update_classid(struct sock *sk)
+{
+}
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	return 0;
diff --git a/include/net/sock.h b/include/net/sock.h
index 72132ae..160a680 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1486,14 +1486,6 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
-#ifdef CONFIG_CGROUPS
-extern void sock_update_classid(struct sock *sk);
-#else
-static inline void sock_update_classid(struct sock *sk)
-{
-}
-#endif
-
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
-- 
1.7.12.315.g682ce8b
