From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [next-queu 03/19] i40e: no need to check is_vsi_in_vlan before calling i40e_del_mac_all_vlan
Date: Thu,  2 Feb 2017 23:25:37 -0800
Message-ID: <20170203072553.168372-4-jeffrey.t.kirsher@intel.com>
References: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:17804 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752706AbdBCHZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 02:25:56 -0500
In-Reply-To: <20170203072553.168372-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This function won't be appreciably slower when in VLAN mode, so there is
no real reason to not just call it directly. In either case, we still
must search the full table for a MAC/VLAN pair. We do get to stop
searching a tiny bit early in the case of knowing we are not in VLAN
mode, but this is a minor savings and we can avoid the code complexity
by not having to worry about the check.

Change-ID: I533412195b3a42f51cf629e3675dd5145aea8625
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7a11d2b..ab0a04b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1779,10 +1779,7 @@ static int i40e_addr_unsync(struct net_device *netdev, const u8 *addr)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	if (i40e_is_vsi_in_vlan(vsi))
-		i40e_del_mac_all_vlan(vsi, addr);
-	else
-		i40e_del_filter(vsi, addr, I40E_VLAN_ANY);
+	i40e_del_mac_all_vlan(vsi, addr);
 
 	return 0;
 }
-- 
2.10.2
