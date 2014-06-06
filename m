From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] i40e: set lan_veb index
Date: Fri,  6 Jun 2014 02:04:10 -0700
Message-ID: <1402045462-10304-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47817 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbaFFJEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2014 05:04:54 -0400
In-Reply-To: <1402045462-10304-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When the VEB is created for the basic LAN device and its VSIs, we need to
set the tracking lan_veb index for later use.

Change-ID: I66bb74993bbda3621ca557437cb4b3517f9b315b
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 35e5ba4..a08f5a0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7735,6 +7735,8 @@ struct i40e_veb *i40e_veb_setup(struct i40e_pf *pf, u16 flags,
 	ret = i40e_add_veb(veb, pf->vsi[vsi_idx]);
 	if (ret)
 		goto err_veb;
+	if (vsi_idx == pf->lan_vsi)
+		pf->lan_veb = veb->idx;
 
 	return veb;
 
-- 
1.9.3
