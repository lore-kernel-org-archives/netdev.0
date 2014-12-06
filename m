From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/16] i40e: Re enable Main VSI loopback setting in the reset path
Date: Sat,  6 Dec 2014 05:02:09 -0800
Message-ID: <1417870933-17248-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8816 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684AbaLFNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:03:00 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 9aa2491..b38aa7a 100644
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
