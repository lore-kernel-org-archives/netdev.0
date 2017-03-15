From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/12] i40e: Allow untrusted VFs to have more filters
Date: Wed, 15 Mar 2017 02:25:43 -0700
Message-ID: <20170315092545.63654-11-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55547 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752511AbdCOJ0B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:26:01 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Our original filter limit of 8 was based on behavior that we saw from
Linux VMs. Now we're running Other Operating Systems under KVM and we
see that they commonly use more MAC filters. Since it seems weird to
require people to enable trusted VFs just to boot their OS, bump the
number of filters allowed by default.

Change-ID: I76b2dcb2ad6017e39231ad3096c3fb6f065eef5e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 115a7286ab8f..cfe8b78dac0e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1851,7 +1851,7 @@ static int i40e_vc_get_stats_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 }
 
 /* If the VF is not trusted restrict the number of MAC/VLAN it can program */
-#define I40E_VC_MAX_MAC_ADDR_PER_VF 8
+#define I40E_VC_MAX_MAC_ADDR_PER_VF 12
 #define I40E_VC_MAX_VLAN_PER_VF 8
 
 /**
-- 
2.12.0
