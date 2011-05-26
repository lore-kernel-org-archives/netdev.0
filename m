From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next when it opens] net: 8021q: Add pr_fmt
Date: Thu, 26 May 2011 13:58:31 -0700
Message-ID: <6d2f6a1e6365b8865fd210e88d257ca0bc7ad0fa.1306442986.git.joe@perches.com>
References: <20110526.145601.735416831290933990.davem@davemloft.net>
Cc: Ben Greear <greearb@candelatech.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526.145601.735416831290933990.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging style.

Add #define pr_fmt and remove embedded prefix from formats.

Not converting the current pr_<level> uses to netdev_<level>
because all the output here is nicely prefaced with "8021q: ".

Remove __func__ use from proc registration failure message.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan.c     |   15 ++++++++-------
 net/8021q/vlan_dev.c |    4 +++-
 net/8021q/vlanproc.c |    4 +++-
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index c7a581a..cfa9afe 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -18,6 +18,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
@@ -149,13 +151,13 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
-		pr_info("8021q: VLANs not supported on %s\n", name);
+		pr_info("VLANs not supported on %s\n", name);
 		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    (!ops->ndo_vlan_rx_add_vid || !ops->ndo_vlan_rx_kill_vid)) {
-		pr_info("8021q: Device %s has buggy VLAN hw accel\n", name);
+		pr_info("Device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
 
@@ -344,13 +346,12 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 	case NETDEV_CHANGENAME:
 		vlan_proc_rem_dev(dev);
 		if (vlan_proc_add_dev(dev) < 0)
-			pr_warning("8021q: failed to change proc name for %s\n",
-					dev->name);
+			pr_warn("failed to change proc name for %s\n",
+				dev->name);
 		break;
 	case NETDEV_REGISTER:
 		if (vlan_proc_add_dev(dev) < 0)
-			pr_warning("8021q: failed to add proc entry for %s\n",
-					dev->name);
+			pr_warn("failed to add proc entry for %s\n", dev->name);
 		break;
 	case NETDEV_UNREGISTER:
 		vlan_proc_rem_dev(dev);
@@ -374,7 +375,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	if ((event == NETDEV_UP) &&
 	    (dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    dev->netdev_ops->ndo_vlan_rx_add_vid) {
-		pr_info("8021q: adding VLAN 0 to HW filter on device %s\n",
+		pr_info("adding VLAN 0 to HW filter on device %s\n",
 			dev->name);
 		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
 	}
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f247f5b..4225e24 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -20,6 +20,8 @@
  *		2 of the License, or (at your option) any later version.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/skbuff.h>
@@ -55,7 +57,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 		return arp_find(veth->h_dest, skb);
 #endif
 	default:
-		pr_debug("%s: unable to resolve type %X addresses.\n",
+		pr_debug("%s: unable to resolve type %X addresses\n",
 			 dev->name, ntohs(veth->h_vlan_encapsulated_proto));
 
 		memcpy(veth->h_source, dev->dev_addr, ETH_ALEN);
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index d940c49..016d7f4 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -17,6 +17,8 @@
  * Jan 20, 1998        Ben Greear     Initial Version
  *****************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -155,7 +157,7 @@ int __net_init vlan_proc_init(struct net *net)
 	return 0;
 
 err:
-	pr_err("%s: can't create entry in proc filesystem!\n", __func__);
+	pr_err("can't create entry in proc filesystem!\n");
 	vlan_proc_cleanup(net);
 	return -ENOBUFS;
 }
-- 
1.7.5.rc3.dirty
