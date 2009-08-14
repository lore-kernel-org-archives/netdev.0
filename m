From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 06/12] vlan: Add support for
	net_devices_ops.ndo_fcoe_control to VLAN
Date: Fri, 14 Aug 2009 15:43:03 -0700
Message-ID: <20090814224303.1640.94218.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:46796 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049AbZHNWnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 18:43:20 -0400
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds implementation of the net_devices_ops.ndo_fcoe_control to the VLAN
driver. It checks if the real_dev has support for ndo_fcoe_control and pass on
to call the associated real_dev->netdevice_ops->ndo_fcoe_control.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan_dev.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6e695ac..9a4ddf5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -586,6 +586,17 @@ static int vlan_dev_fcoe_ddp_done(struct net_device *dev, u16 xid)
 
 	return len;
 }
+
+static int vlan_dev_fcoe_control(struct net_device *dev, u32 op)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int rc = -EINVAL;
+
+	if (ops->ndo_fcoe_control)
+		rc = ops->ndo_fcoe_control(real_dev, op);
+	return rc;
+}
 #endif
 
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
@@ -749,6 +760,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_control	= vlan_dev_fcoe_control,
 #endif
 };
 
@@ -769,6 +781,7 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_control	= vlan_dev_fcoe_control,
 #endif
 };
 

