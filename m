From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/8] vlan: Add support for
	net_devices_ops.ndo_fcoe_enable/_disable to VLAN
Date: Mon, 31 Aug 2009 15:31:55 -0700
Message-ID: <20090831223154.30995.11005.stgit@localhost.localdomain>
References: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:34601 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752036AbZHaWcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:32:10 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds implementation of the net_devices_ops.ndo_fcoe_enable/_disable to
the VLAN driver. It checks if the real_dev has support for ndo_fcoe_enable/
ndo_fcoe_disable and if so, passes on to call the associated real_dev.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan_dev.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6e695ac..5a23958 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -586,6 +586,28 @@ static int vlan_dev_fcoe_ddp_done(struct net_device *dev, u16 xid)
 
 	return len;
 }
+
+static int vlan_dev_fcoe_enable(struct net_device *dev)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int rc = -EINVAL;
+
+	if (ops->ndo_fcoe_enable)
+		rc = ops->ndo_fcoe_enable(real_dev);
+	return rc;
+}
+
+static int vlan_dev_fcoe_disable(struct net_device *dev)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int rc = -EINVAL;
+
+	if (ops->ndo_fcoe_disable)
+		rc = ops->ndo_fcoe_disable(real_dev);
+	return rc;
+}
 #endif
 
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
@@ -749,6 +771,8 @@ static const struct net_device_ops vlan_netdev_ops = {
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
+	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
 #endif
 };
 
@@ -769,6 +793,8 @@ static const struct net_device_ops vlan_netdev_accel_ops = {
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	.ndo_fcoe_ddp_setup	= vlan_dev_fcoe_ddp_setup,
 	.ndo_fcoe_ddp_done	= vlan_dev_fcoe_ddp_done,
+	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
+	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
 #endif
 };
 

