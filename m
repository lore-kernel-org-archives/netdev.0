From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netprio_cgroup: Fix build break
Date: Wed, 23 Nov 2011 07:32:33 -0500
Message-ID: <1322051553-28987-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Kirill Smelkov <kirr@mns.spb.ru>,
	"David S. Miller" <davem@davemloft.net>,
	john.r.fastabend@intel.com, robert.w.love@intel.com,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I broke the build with the addition of netprio_cgroups if CONFIG_CGROUPS=n.
This patch corrects it by moving the offending struct into an ifdef
CONFIG_CGROUPS block.  Also clean up a few needless defines and inline functions
that don't get called if CONFIG_CGROUPS isn't defined while Im at it.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Kirill Smelkov <kirr@mns.spb.ru>
CC: "David S. Miller" <davem@davemloft.net>
CC: john.r.fastabend@intel.com
CC: robert.w.love@intel.com
CC: Stephen Rothwell <sfr@canb.auug.org.au>
CC: linux-next@vger.kernel.org
---
 include/net/netprio_cgroup.h |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index c432e99..e503b87 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -18,11 +18,6 @@
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-struct cgroup_netprio_state
-{
-	struct cgroup_subsys_state css;
-	u32 prioidx;
-};
 
 struct netprio_map {
 	struct rcu_head rcu;
@@ -32,6 +27,11 @@ struct netprio_map {
 
 #ifdef CONFIG_CGROUPS
 
+struct cgroup_netprio_state {
+	struct cgroup_subsys_state css;
+	u32 prioidx;
+};
+
 #ifndef CONFIG_NETPRIO_CGROUP
 extern int net_prio_subsys_id;
 #endif
@@ -52,14 +52,6 @@ static inline struct cgroup_netprio_state
 #else
 
 #define sock_update_netprioidx(sk)
-#define skb_update_prio(skb)
-
-static inline struct cgroup_netprio_state
-		*task_netprio_state(struct task_struct *p)
-{
-	return NULL;
-}
-
 #endif
 
 #endif  /* _NET_CLS_CGROUP_H */
-- 
1.7.6.4
