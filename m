From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40e: Re enable Main VSI loopback setting in the reset path
Date: Fri, 21 Nov 2014 21:55:03 -0800
Message-ID: <1416635708-4765-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:50713 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750871AbaKVFzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:18 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

There is an order in which this should happen. It turns out that FW will
not let you change the Loopback setting of the VSI with update VSI prior
to the VEB creation.

Change-ID: I7614ddff8b4c37702930c02f16f8c346aaa64bd1
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 99be5d0..a7090f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5888,6 +5888,9 @@ static int i40e_reconstitute_veb(struct i40e_veb *veb)
 	if (ret)
 		goto end_reconstitute;
 
+	/* Enable LB mode for the main VSI now that it is on a VEB */
+	i40e_enable_pf_switch_lb(pf);
+
 	/* create the remaining VSIs attached to this VEB */
 	for (v = 0; v < pf->num_alloc_vsi; v++) {
 		if (!pf->vsi[v] || pf->vsi[v] == ctl_vsi)
-- 
1.9.3
