From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 1/4] net: Add support to netdev ops for changing hardware
	queue MAC and VLAN filters
Date: Tue, 17 Nov 2009 13:50:01 -0800
Message-ID: <20091117214923.15119.98918.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:58191
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753569AbZKQVuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:50:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7043f85..6a70365 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -610,6 +610,8 @@ struct netdev_queue {
  *	this function is called when a VLAN id is unregistered.
  *
  * void (*ndo_poll_controller)(struct net_device *dev);
+ * int (*ndo_set_queue_mac)(struct net_device *dev, int queue, u8* mac);
+ * int (*ndo_set_queue_vlan)(struct net_device *dev, int queue, u16 vlan);
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -659,6 +661,10 @@ struct net_device_ops {
 #define HAVE_NETDEV_POLL
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 #endif
+	int			(*ndo_set_queue_mac)(struct net_device *dev,
+						     int queue, u8 *mac);
+	int			(*ndo_set_queue_vlan)(struct net_device *dev,
+						      int queue, u16 vlan);
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);

