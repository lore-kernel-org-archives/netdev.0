From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] i40e: use generic vsi_open to unquiesce vsi
Date: Tue, 22 Apr 2014 05:39:27 -0700
Message-ID: <1398170371-3333-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3866 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932615AbaDVMjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:42 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use the new i40e_vsi_open() for waking VSIs back up in order to
be sure all the standard actions happen.

Change-ID: Ic3479410dd3079733f4951dcea69f101e69e77df
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2210ab2..7bbecf8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3560,7 +3560,7 @@ static void i40e_unquiesce_vsi(struct i40e_vsi *vsi)
 	if (vsi->netdev && netif_running(vsi->netdev))
 		vsi->netdev->netdev_ops->ndo_open(vsi->netdev);
 	else
-		i40e_up(vsi);   /* this clears the DOWN bit */
+		i40e_vsi_open(vsi);   /* this clears the DOWN bit */
 }
 
 /**
-- 
1.9.0
