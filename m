From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 4/6] net: Add netdev ops for SR-IOV configuration
Date: Thu, 17 Dec 2009 17:34:44 -0800
Message-ID: <20091218013444.4510.33545.stgit@localhost.localdomain>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:55690
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752635AbZLRBfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:35:00 -0500
In-Reply-To: <20091218013329.4510.25937.stgit@localhost.localdomain>
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
index f6e521e..0e42077 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -28,6 +28,7 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
+#include <linux/if_link.h>
 
 #ifdef __KERNEL__
 #include <linux/timer.h>
@@ -611,6 +612,13 @@ struct netdev_queue {
  *	this function is called when a VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
+ *
+ *	SR-IOV management functions.
+ * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
+ * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan);
+ * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate);
+ * int (*ndo_get_vf_config)(struct net_device *dev,
+ *			    int vf, struct ifla_vf_info *ivf);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -660,6 +668,15 @@ struct net_device_ops {
 #define HAVE_NETDEV_POLL
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
+	int			(*ndo_set_vf_mac)(struct net_device *dev,
+						  int queue, u8 *mac);
+	int			(*ndo_set_vf_vlan)(struct net_device *dev,
+						   int queue, u16 vlan);
+	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
+						      int vf, int rate);
+	int			(*ndo_get_vf_config)(struct net_device *dev,
+						     int vf,
+						     struct ifla_vf_info *ivf);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);

