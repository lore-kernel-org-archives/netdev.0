From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e: add 20G speed for Tx bandwidth calculations
Date: Tue, 16 Feb 2016 21:34:15 -0800
Message-ID: <1455687262-20453-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:43674 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756400AbcBQFe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 00:34:27 -0500
In-Reply-To: <1455687262-20453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When calculating TX bandwidth for VFs, we need to know the link speed to
make sure we don't allocate more bandwidth than is available. Add 20G
link speed to the switch statement so we can support devices that link
at that speed.

Change-ID: I5409f6139d549e5832777db9c22ca0664e0c5f8b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 659d782..1635c7a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2306,6 +2306,9 @@ int i40e_ndo_set_vf_bw(struct net_device *netdev, int vf_id, int min_tx_rate,
 	case I40E_LINK_SPEED_40GB:
 		speed = 40000;
 		break;
+	case I40E_LINK_SPEED_20GB:
+		speed = 20000;
+		break;
 	case I40E_LINK_SPEED_10GB:
 		speed = 10000;
 		break;
-- 
2.5.0
