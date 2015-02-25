From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: setup FCoE device type
Date: Wed, 25 Feb 2015 00:58:35 -0800
Message-ID: <1424854720-18825-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbbBYI6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:49 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Setup FCoE netdev device type as "fcoe", so that it shows up in
sysfs as FCoE device.

Change-ID: Ie13a1a332dba4d5802586926104ee01ef20da44f
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index cc11868..05d883e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1474,6 +1474,11 @@ static const struct net_device_ops i40e_fcoe_netdev_ops = {
 	.ndo_set_features	= i40e_fcoe_set_features,
 };
 
+/* fcoe network device type */
+static struct device_type fcoe_netdev_type = {
+	.name = "fcoe",
+};
+
 /**
  * i40e_fcoe_config_netdev - prepares the VSI context for creating a FCoE VSI
  * @vsi: pointer to the associated VSI struct
@@ -1507,6 +1512,7 @@ void i40e_fcoe_config_netdev(struct net_device *netdev, struct i40e_vsi *vsi)
 	strlcpy(netdev->name, "fcoe%d", IFNAMSIZ-1);
 	netdev->mtu = FCOE_MTU;
 	SET_NETDEV_DEV(netdev, &pf->pdev->dev);
+	SET_NETDEV_DEVTYPE(netdev, &fcoe_netdev_type);
 	/* set different dev_port value 1 for FCoE netdev than the default
 	 * zero dev_port value for PF netdev, this helps biosdevname user
 	 * tool to differentiate them correctly while both attached to the
-- 
1.9.3
