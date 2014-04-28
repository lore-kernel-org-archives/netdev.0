From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Do not enable NTUPLE feature control in MFP mode
Date: Mon, 28 Apr 2014 06:52:34 -0700
Message-ID: <1398693158-2815-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917AbaD1Nwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:47 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Although NTUPLE feature control is disabled by default, do not
allow user to be able to change it.

Change-ID: I4c3f95fb6dbc56b1b6cc47116ea1f72de02bc99c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 126be0d..5506561 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6783,10 +6783,12 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			   NETIF_F_TSO_ECN	       |
 			   NETIF_F_TSO6		       |
 			   NETIF_F_RXCSUM	       |
-			   NETIF_F_NTUPLE	       |
 			   NETIF_F_RXHASH	       |
 			   0;
 
+	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
+		netdev->features |= NETIF_F_NTUPLE;
+
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
 
-- 
1.9.0
