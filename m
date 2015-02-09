From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: use dev_port for fcoe netdev
Date: Mon,  9 Feb 2015 02:43:59 -0800
Message-ID: <1423478641-3138-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759974AbbBIKoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:07 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Set different dev_port value 1 for FCoE netdev than the default zero
dev_port value for PF netdev, this helps biosdevname user tool to
differentiate them correctly while both attached to the same PCI
function.

Change-ID: I8fb90e4ef52a1242f7580e49a3f0918735aee8ef
Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index dc8cbdd..401f7ed 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -1502,6 +1502,12 @@ void i40e_fcoe_config_netdev(struct net_device *netdev, struct i40e_vsi *vsi)
 	strlcpy(netdev->name, "fcoe%d", IFNAMSIZ-1);
 	netdev->mtu = FCOE_MTU;
 	SET_NETDEV_DEV(netdev, &pf->pdev->dev);
+	/* set different dev_port value 1 for FCoE netdev than the default
+	 * zero dev_port value for PF netdev, this helps biosdevname user
+	 * tool to differentiate them correctly while both attached to the
+	 * same PCI function.
+	 */
+	netdev->dev_port = 1;
 	i40e_add_filter(vsi, hw->mac.san_addr, 0, false, false);
 	i40e_add_filter(vsi, (u8[6]) FC_FCOE_FLOGI_MAC, 0, false, false);
 	i40e_add_filter(vsi, FIP_ALL_FCOE_MACS, 0, false, false);
-- 
1.9.3
