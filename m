From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] i40e: fix a bug in debugfs with add/del macaddr
Date: Fri, 23 Oct 2015 06:17:44 -0700
Message-ID: <1445606279-19345-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:13278 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751079AbbJWNSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:17 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The new code flow requires us to grab the filter list lock before
adding/deleting the filter.

Change-ID: I4eaef508ab4da2d1b2e23f20f2a78d931d5b6aeb
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d15bd62..d4b7af9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1137,7 +1137,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			goto command_write_done;
 		}
 
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		f = i40e_add_filter(vsi, ma, vlan, false, false);
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 		ret = i40e_sync_vsi_filters(vsi, true);
 		if (f && !ret)
 			dev_info(&pf->pdev->dev,
@@ -1174,7 +1176,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			goto command_write_done;
 		}
 
+		spin_lock_bh(&vsi->mac_filter_list_lock);
 		i40e_del_filter(vsi, ma, vlan, false, false);
+		spin_unlock_bh(&vsi->mac_filter_list_lock);
 		ret = i40e_sync_vsi_filters(vsi, true);
 		if (!ret)
 			dev_info(&pf->pdev->dev,
-- 
2.4.3
