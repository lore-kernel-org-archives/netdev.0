From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/16] i40evf: use capabilities flags properly
Date: Thu,  8 Oct 2015 18:32:52 -0700
Message-ID: <1444354374-24351-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:37035 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755560AbbJIBdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:00 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Use the capabilities passed to us by the PF driver to control VF driver
behavior. In the process, clean up the VLAN add/remove code so it's not
a horrible morass of ifdefs.

Change-ID: I1050eaf12b658a26fea6813047c9964163c70a73
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 664fde6..1f99930 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -730,6 +730,8 @@ static int i40evf_vlan_rx_add_vid(struct net_device *netdev,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
+	if (!VLAN_ALLOWED(adapter))
+		return -EIO;
 	if (i40evf_add_vlan(adapter, vid) == NULL)
 		return -ENOMEM;
 	return 0;
@@ -745,8 +747,11 @@ static int i40evf_vlan_rx_kill_vid(struct net_device *netdev,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
-	i40evf_del_vlan(adapter, vid);
-	return 0;
+	if (VLAN_ALLOWED(adapter)) {
+		i40evf_del_vlan(adapter, vid);
+		return 0;
+	}
+	return -EIO;
 }
 
 /**
-- 
2.4.3
