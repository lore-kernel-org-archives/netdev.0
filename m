From: Amerigo Wang <amwang@redhat.com>
Subject: [PATCH 2/5] net: move netdevice notifiers into netdevice.h
Date: Wed, 22 Jun 2011 14:35:19 +0800
Message-ID: <1308724522-32461-3-git-send-email-amwang@redhat.com>
References: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1308724522-32461-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not necessary to share the same notifier.h.

Signed-off-by: WANG Cong <amwang@redhat.com>
---
 include/linux/netdevice.h |   36 +++++++++++++++++++++++++++++++++---
 include/linux/notifier.h  |   28 +---------------------------
 2 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 54b8b4d..7c2026b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1566,6 +1566,39 @@ struct packet_type {
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 
+/* netdevice notifier chain. Please remember to update the rtnetlink
+ * notification exclusion list in rtnetlink_event() when adding new
+ * types.
+ */
+#define NETDEV_UP	0x0001	/* For now you can't veto a device up/down */
+#define NETDEV_DOWN	0x0002
+#define NETDEV_REBOOT	0x0003	/* Tell a protocol stack a network interface
+				   detected a hardware crash and restarted
+				   - we can use this eg to kick tcp sessions
+				   once done */
+#define NETDEV_CHANGE	0x0004	/* Notify device state change */
+#define NETDEV_REGISTER 0x0005
+#define NETDEV_UNREGISTER	0x0006
+#define NETDEV_CHANGEMTU	0x0007
+#define NETDEV_CHANGEADDR	0x0008
+#define NETDEV_GOING_DOWN	0x0009
+#define NETDEV_CHANGENAME	0x000A
+#define NETDEV_FEAT_CHANGE	0x000B
+#define NETDEV_BONDING_FAILOVER 0x000C
+#define NETDEV_PRE_UP		0x000D
+#define NETDEV_PRE_TYPE_CHANGE	0x000E
+#define NETDEV_POST_TYPE_CHANGE	0x000F
+#define NETDEV_POST_INIT	0x0010
+#define NETDEV_UNREGISTER_BATCH 0x0011
+#define NETDEV_RELEASE		0x0012
+#define NETDEV_NOTIFY_PEERS	0x0013
+#define NETDEV_JOIN		0x0014
+
+extern int register_netdevice_notifier(struct notifier_block *nb);
+extern int unregister_netdevice_notifier(struct notifier_block *nb);
+extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
+
+
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 
@@ -1648,12 +1681,9 @@ static inline void unregister_netdevice(struct net_device *dev)
 extern int 		netdev_refcnt_read(const struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
-extern int 		register_netdevice_notifier(struct notifier_block *nb);
-extern int		unregister_netdevice_notifier(struct notifier_block *nb);
 extern int		init_dummy_netdev(struct net_device *dev);
 extern void		netdev_resync_ops(struct net_device *dev);
 
-extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*dev_get_by_index_rcu(struct net *net, int ifindex);
diff --git a/include/linux/notifier.h b/include/linux/notifier.h
index 9eb25fc..e8a858a 100644
--- a/include/linux/notifier.h
+++ b/include/linux/notifier.h
@@ -187,33 +187,7 @@ static inline int notifier_to_errno(int ret)
  
 /* CPU notfiers are defined in include/linux/cpu.h. */
 
-/* netdevice notifier chain. Please remember to update the rtnetlink
- * notification exclusion list in rtnetlink_event() when adding new
- * types.
- */
-#define NETDEV_UP	0x0001	/* For now you can't veto a device up/down */
-#define NETDEV_DOWN	0x0002
-#define NETDEV_REBOOT	0x0003	/* Tell a protocol stack a network interface
-				   detected a hardware crash and restarted
-				   - we can use this eg to kick tcp sessions
-				   once done */
-#define NETDEV_CHANGE	0x0004	/* Notify device state change */
-#define NETDEV_REGISTER 0x0005
-#define NETDEV_UNREGISTER	0x0006
-#define NETDEV_CHANGEMTU	0x0007
-#define NETDEV_CHANGEADDR	0x0008
-#define NETDEV_GOING_DOWN	0x0009
-#define NETDEV_CHANGENAME	0x000A
-#define NETDEV_FEAT_CHANGE	0x000B
-#define NETDEV_BONDING_FAILOVER 0x000C
-#define NETDEV_PRE_UP		0x000D
-#define NETDEV_PRE_TYPE_CHANGE	0x000E
-#define NETDEV_POST_TYPE_CHANGE	0x000F
-#define NETDEV_POST_INIT	0x0010
-#define NETDEV_UNREGISTER_BATCH 0x0011
-#define NETDEV_RELEASE		0x0012
-#define NETDEV_NOTIFY_PEERS	0x0013
-#define NETDEV_JOIN		0x0014
+/* netdevice notifiers are defined in include/linux/netdevice.h */
 
 #define SYS_DOWN	0x0001	/* Notify of system down */
 #define SYS_RESTART	SYS_DOWN
-- 
1.7.4.4
