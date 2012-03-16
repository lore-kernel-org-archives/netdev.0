From: Tony Breeds <tony@bakeyournoodle.com>
Subject: [PATCH] Replace IS_ENABLED(CONFIG_FCOE) in linux/netdevice.h
Date: Fri, 16 Mar 2012 11:30:15 +1100
Message-ID: <1331857815-2333-1-git-send-email-tony@bakeyournoodle.com>
Cc: devel@open-fcoe.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On platforms that (or configs that do not have PCI support building any
code that includes linux/netdevice.h we see the following warnings:

include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE" is not defined [-Wundef]
include/linux/netdevice.h:964:1: warning: "__enabled_CONFIG_FCOE_MODULE" is not defined [-Wundef]

In the case of this file we can trivially fallback to the old school
 #if defined(...) syntax.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
To: Robert Love <robert.w.love@intel.com>
To: "James E.J. Bottomley" <JBottomley@parallels.com>
To: "David S. Miller" <davem@davemloft.net>
CC: devel@open-fcoe.org
CC: netdev@vger.kernel.org
CC: linux-scsi@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 include/linux/netdevice.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0eac07c..3e4bbbc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -961,7 +961,7 @@ struct net_device_ops {
 	int			(*ndo_get_vf_port)(struct net_device *dev,
 						   int vf, struct sk_buff *skb);
 	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
-#if IS_ENABLED(CONFIG_FCOE)
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
 	int			(*ndo_fcoe_ddp_setup)(struct net_device *dev,
@@ -978,7 +978,7 @@ struct net_device_ops {
 							struct netdev_fcoe_hbainfo *hbainfo);
 #endif
 
-#if IS_ENABLED(CONFIG_LIBFCOE)
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 #define NETDEV_FCOE_WWNN 0
 #define NETDEV_FCOE_WWPN 1
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
@@ -1286,7 +1286,7 @@ struct net_device {
 	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
 	u8 prio_tc_map[TC_BITMASK + 1];
 
-#if IS_ENABLED(CONFIG_FCOE)
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
-- 
1.7.7.6

