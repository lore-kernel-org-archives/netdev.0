From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] i40e: add MAC printing to debugfs dump VSI
Date: Mon,  9 Mar 2015 10:55:40 -0700
Message-ID: <1425923742-4488-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56922 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753395AbbCIRzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:46 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Print the LAN, SAN, and Port MACs for the VSI if debugfs command
dump VSI is used on the PF's VSI.

Example output:
[260221.871244] i40e 0000:04:00.0: MAC address: 68:05:ca:26:15:e0 SAN MAC: 00:00:00:00:02:00 Port MAC: 68:05:ca:26:15:e3

Change-ID: I0b393113dfb5ee7ff4f9e5227e4177885f0cc15e
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 2cc73fe..daa8826 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -390,6 +390,11 @@ static void i40e_dbg_dump_vsi_seid(struct i40e_pf *pf, int seid)
 		 "    netdev_registered = %i, current_netdev_flags = 0x%04x, state = %li flags = 0x%08lx\n",
 		 vsi->netdev_registered,
 		 vsi->current_netdev_flags, vsi->state, vsi->flags);
+	if (vsi == pf->vsi[pf->lan_vsi])
+		dev_info(&pf->pdev->dev, "MAC address: %pM SAN MAC: %pM Port MAC: %pM\n",
+			 pf->hw.mac.addr,
+			 pf->hw.mac.san_addr,
+			 pf->hw.mac.port_addr);
 	list_for_each_entry(f, &vsi->mac_filter_list, list) {
 		dev_info(&pf->pdev->dev,
 			 "    mac_filter_list: %pM vid=%d, is_netdev=%d is_vf=%d counter=%d\n",
-- 
1.9.3
