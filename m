From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v3 3/5] net: Add netdev ops for SR-IOV
	configuration
Date: Wed, 10 Feb 2010 03:43:46 -0800
Message-ID: <20100210114344.14483.81331.stgit@localhost.localdomain>
References: <20100210114303.14483.71368.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:55149 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760Ab0BJLoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:44:03 -0500
In-Reply-To: <20100210114303.14483.71368.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add netdev ops for configuring SR-IOV VF devices through the PF driver.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e535700..49ef6d8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -28,6 +28,7 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
+#include <linux/if_link.h>
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
@@ -621,6 +622,13 @@ struct netdev_queue {
  *	this function is called when a VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
+ *
+ *	SR-IOV management functions.
+ * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
+ * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8 qos);
+ * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_get_vf_config)(struct net_device *dev,
+ *			    int vf, struct ifla_vf_info *ivf);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -660,6 +668,15 @@ struct net_device_ops {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
+	int			(*ndo_set_vf_mac)(struct net_device *dev,
+						  int queue, u8 *mac);
+	int			(*ndo_set_vf_vlan)(struct net_device *dev,
+						   int queue, u16 vlan, u8 qos);
+	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
+						      int vf, int rate);
+	int			(*ndo_get_vf_config)(struct net_device *dev,
+						     int vf,
+						     struct ifla_vf_info *ivf);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);

