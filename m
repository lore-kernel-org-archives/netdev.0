From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e: set context to use VSI RSS LUT for SR-IOV
Date: Sat, 14 May 2016 21:57:31 -0700
Message-ID: <1463288255-1654-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752509AbcEOE5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:42 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

For the SR-IOV VSIs, when the queue filtering section is valid,
the RSS LUT needs to be set to use the VSI specific lookup table
(otherwise it will use the PF RSS LUT table).

Change-ID: Ia9377cc818078238a75c3bdeade1b593a91b3480
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f8038d0..a981246 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9362,7 +9362,8 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 			ctxt.info.valid_sections |=
 				cpu_to_le16(I40E_AQ_VSI_PROP_QUEUE_OPT_VALID);
 			ctxt.info.queueing_opt_flags |=
-						I40E_AQ_VSI_QUE_OPT_TCP_ENA;
+				(I40E_AQ_VSI_QUE_OPT_TCP_ENA |
+				 I40E_AQ_VSI_QUE_OPT_RSS_LUT_VSI);
 		}
 
 		ctxt.info.valid_sections |= cpu_to_le16(I40E_AQ_VSI_PROP_VLAN_VALID);
-- 
2.5.5
