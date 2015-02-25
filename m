From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: print Rx packet split status
Date: Wed, 25 Feb 2015 00:58:36 -0800
Message-ID: <1424854720-18825-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbbBYI6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:49 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add the RX routine in use to the features log message.

Change-ID: Ifbbf28fb7f42b9a3d2828586488e9e6331107dd5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 97a759a..39e4f35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9356,8 +9356,10 @@ static void i40e_print_features(struct i40e_pf *pf)
 #ifdef CONFIG_PCI_IOV
 	buf += sprintf(buf, "VFs: %d ", pf->num_req_vfs);
 #endif
-	buf += sprintf(buf, "VSIs: %d QP: %d ", pf->hw.func_caps.num_vsis,
-		       pf->vsi[pf->lan_vsi]->num_queue_pairs);
+	buf += sprintf(buf, "VSIs: %d QP: %d RX: %s ",
+		       pf->hw.func_caps.num_vsis,
+		       pf->vsi[pf->lan_vsi]->num_queue_pairs,
+		       pf->flags & I40E_FLAG_RX_PS_ENABLED ? "PS" : "1BUF");
 
 	if (pf->flags & I40E_FLAG_RSS_ENABLED)
 		buf += sprintf(buf, "RSS ");
-- 
1.9.3
