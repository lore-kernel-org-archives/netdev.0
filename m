From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] i40e: Stop the VF device after setting its MAC address
Date: Mon, 23 Jun 2014 17:47:25 -0700
Message-ID: <1403570858-13548-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58389 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405AbaFXArm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 20:47:42 -0400
In-Reply-To: <1403570858-13548-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

If the host VMM administrator has changed the VF device's MAC address then
the i40e driver needs to halt the VF device so that the administrator will
be forced to reload the VF driver.  This will cause the VF driver to start
using the newly assigned MAC address.  This brings the i40e driver into
conformance with operational characteristics of other Intel SR-IOV
featured drivers.

Change-ID: Ic7242cceb8287dd2cb72fb1f3166a032a28bf88a
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index f5b9d20..d2dabae 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2077,6 +2077,8 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	}
 	ether_addr_copy(vf->default_lan_addr.addr, mac);
 	vf->pf_set_mac = true;
+	/* Force the VF driver stop so it has to reload with new MAC address */
+	i40e_vc_disable_vf(pf, vf);
 	dev_info(&pf->pdev->dev, "Reload the VF driver to make this change effective.\n");
 	ret = 0;
 
-- 
1.9.3
