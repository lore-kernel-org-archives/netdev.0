From: Kiran Patil <kiran.patil@intel.com>
Subject: [RFC PATCH 2/2] vlan: add support to ndo_fcoe_ddp_target()
Date: Wed, 26 Jan 2011 10:09:06 -0800
Message-ID: <20110126180906.25039.19009.stgit@localhost.localdomain>
References: <20110126180855.25039.82793.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	yi.zou@intel.com, robert.w.love@intel.com, kiran.patil@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32445 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990Ab1AZSHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 13:07:07 -0500
In-Reply-To: <20110126180855.25039.82793.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add the new target ddp offload support ndo_fcoe_ddp_target().

Signed-off-by: Yi Zou <yi.zou@intel.com>
---

 net/8021q/vlan_dev.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 14e3d1f..f6e1ace 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -670,6 +670,19 @@ static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
 		rc = ops->ndo_fcoe_get_wwn(real_dev, wwn, type);
 	return rc;
 }
+
+static int vlan_dev_fcoe_ddp_target(struct net_device *dev, u16 xid,
+				    struct scatterlist *sgl, unsigned int sgc)
+{
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
+	int rc = 0;
+
+	if (ops->ndo_fcoe_ddp_target)
+		rc = ops->ndo_fcoe_ddp_target(real_dev, xid, sgl, sgc);
+
+	return rc;
+}
 #endif
 
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
@@ -905,6 +918,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
 	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
 	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
+	.ndo_fcoe_ddp_target	= vlan_dev_fcoe_ddp_target,
 #endif
 };
 

