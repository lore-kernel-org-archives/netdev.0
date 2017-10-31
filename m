From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [RFC PATCH 06/14] netdevice: add AF_PACKET V4 zerocopy ops
Date: Tue, 31 Oct 2017 13:41:37 +0100
Message-ID: <20171031124145.9667-7-bjorn.topel@gmail.com>
References: <20171031124145.9667-1-bjorn.topel@gmail.com>
Cc: jesse.brandeburg@intel.com, anjali.singhai@intel.com,
        rami.rosen@intel.com, jeffrey.b.shaw@intel.com,
        ferruh.yigit@intel.com, qi.z.zhang@intel.com
To: bjorn.topel@gmail.com, magnus.karlsson@intel.com,
        alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
        john.fastabend@gmail.com, ast@fb.com, brouer@redhat.com,
        michael.lundkvist@ericsson.com, ravineet.singh@ericsson.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:11945 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753141AbdJaMmk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 08:42:40 -0400
In-Reply-To: <20171031124145.9667-1-bjorn.topel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Karlsson <magnus.karlsson@intel.com>

Two new ndo ops are added. One for enabling/disabling AF_PACKET V4
zerocopy, and one for kicking the egress ring.

Signed-off-by: Magnus Karlsson <magnus.karlsson@intel.com>
---
 include/linux/netdevice.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5e02f79b2110..1421206bf243 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -833,6 +833,8 @@ struct dev_ifalias {
 	char ifalias[];
 };
 
+struct tp4_netdev_parms;
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1133,6 +1135,15 @@ struct dev_ifalias {
  * void (*ndo_xdp_flush)(struct net_device *dev);
  *	This function is used to inform the driver to flush a particular
  *	xdp tx queue. Must be called on same CPU as xdp_xmit.
+ * int (*ndo_tp4_zerocopy)(struct net_device *dev,
+ *			   struct tp4_netdev_parms *parms);
+ *	This function is used to enable and disable the AF_PACKET V4
+ *	PACKET_ZEROCOPY support. See definition of enum tp4_netdev_command
+ *	in tpacket4.h for details.
+ * int (*ndo_tp4_xmit)(struct net_device *dev, int queue_pair);
+ *	This function is used to send packets when the PACKET_ZEROCOPY
+ *	option is set. The rtnl lock is not held when entering this
+ *	function.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1320,6 +1331,11 @@ struct net_device_ops {
 	int			(*ndo_xdp_xmit)(struct net_device *dev,
 						struct xdp_buff *xdp);
 	void			(*ndo_xdp_flush)(struct net_device *dev);
+	int                     (*ndo_tp4_zerocopy)(
+					struct net_device *dev,
+					struct tp4_netdev_parms *parms);
+	int                     (*ndo_tp4_xmit)(struct net_device *dev,
+						int queue_pair);
 };
 
 /**
-- 
2.11.0
