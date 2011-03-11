From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 02/11] net: add proper documentation for previously added net_device_ops for FCoE
Date: Fri, 11 Mar 2011 03:06:21 -0800
Message-ID: <1299841590-30676-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463Ab1CKLGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:48 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add proper documentation for previously added net_device_ops ops for FCoE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/linux/netdevice.h |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7a07153..604dbf5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -777,6 +777,42 @@ struct netdev_tc_txq {
  * 	queues stopped. This allows the netdevice to perform queue management
  * 	safely.
  *
+ *	Fiber Channel over Ethernet (FCoE) offload functions.
+ * int (*ndo_fcoe_enable)(struct net_device *dev);
+ *	Called when the FCoE protocol stack wants to start using LLD for FCoE
+ *	so the underlying device can perform whatever needed configuration or
+ *	initialization to support acceleration of FCoE traffic.
+ *
+ * int (*ndo_fcoe_disable)(struct net_device *dev);
+ *	Called when the FCoE protocol stack wants to stop using LLD for FCoE
+ *	so the underlying device can perform whatever needed clean-ups to
+ *	stop supporting acceleration of FCoE traffic.
+ *
+ * int (*ndo_fcoe_ddp_setup)(struct net_device *dev, u16 xid,
+ *			     struct scatterlist *sgl, unsigned int sgc);
+ *	Called when the FCoE Initiator wants to initialize an I/O that
+ *	is a possible candidate for Direct Data Placement (DDP). The LLD can
+ *	perform necessary setup and returns 1 to indicate the device is set up
+ *	successfully to perform DDP on this I/O, otherwise this returns 0.
+ *
+ * int (*ndo_fcoe_ddp_done)(struct net_device *dev,  u16 xid);
+ *	Called when the FCoE Initiator/Target is done with the DDPed I/O as
+ *	indicated by the FC exchange id 'xid', so the underlying device can
+ *	clean up and reuse resources for later DDP requests.
+ *
+ * int (*ndo_fcoe_ddp_target)(struct net_device *dev, u16 xid,
+ *			      struct scatterlist *sgl, unsigned int sgc);
+ *	Called when the FCoE Target wants to initialize an I/O that
+ *	is a possible candidate for Direct Data Placement (DDP). The LLD can
+ *	perform necessary setup and returns 1 to indicate the device is set up
+ *	successfully to perform DDP on this I/O, otherwise this returns 0.
+ *
+ * int (*ndo_fcoe_get_wwn)(struct net_device *dev, u64 *wwn, int type);
+ *	Called when the underlying device wants to override default World Wide
+ *	Name (WWN) generation mechanism in FCoE protocol stack to pass its own
+ *	World Wide Port Name (WWPN) or World Wide Node Name (WWNN) to the FCoE
+ *	protocol stack to use.
+ *
  *	RFS acceleration.
  * int (*ndo_rx_flow_steer)(struct net_device *dev, const struct sk_buff *skb,
  *			    u16 rxq_index, u32 flow_id);
-- 
1.7.4

