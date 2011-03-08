From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/14] vlan: add support to ndo_fcoe_ddp_target()
Date: Mon,  7 Mar 2011 18:24:59 -0800
Message-ID: <1299551108-23663-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Kiran Patil <kiran.patil@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab1CHC0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:05 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add the new target ddp offload support ndo_fcoe_ddp_target().

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 net/8021q/vlan_dev.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index be73753..ae610f0 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -625,6 +625,19 @@ static int vlan_dev_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type)
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
@@ -858,6 +871,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_fcoe_enable	= vlan_dev_fcoe_enable,
 	.ndo_fcoe_disable	= vlan_dev_fcoe_disable,
 	.ndo_fcoe_get_wwn	= vlan_dev_fcoe_get_wwn,
+	.ndo_fcoe_ddp_target	= vlan_dev_fcoe_ddp_target,
 #endif
 };
 
-- 
1.7.4

