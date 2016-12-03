From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/18] i40e: remove second check of VLAN_N_VID in i40e_vlan_rx_add_vid
Date: Sat,  3 Dec 2016 01:19:16 -0800
Message-ID: <20161203091930.14268-5-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28618 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751352AbcLCJUc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:32 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Replace a check of magic number 4095 with VLAN_N_VID. This
makes it obvious that a later check against VLAN_N_VID is
always true and can be removed.

Change-ID: I28998f127a61a529480ce63d8a07e266f6c63b7b
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2d91274..fe5939a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2549,7 +2549,7 @@ static int i40e_vlan_rx_add_vid(struct net_device *netdev,
 	struct i40e_vsi *vsi = np->vsi;
 	int ret = 0;
 
-	if (vid > 4095)
+	if (vid >= VLAN_N_VID)
 		return -EINVAL;
 
 	/* If the network stack called us with vid = 0 then
@@ -2561,7 +2561,7 @@ static int i40e_vlan_rx_add_vid(struct net_device *netdev,
 	if (vid)
 		ret = i40e_vsi_add_vlan(vsi, vid);
 
-	if (!ret && (vid < VLAN_N_VID))
+	if (!ret)
 		set_bit(vid, vsi->active_vlans);
 
 	return ret;
-- 
2.9.3
