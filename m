From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/11] i40e: Update VEB's enabled_tc after reconfiguration
Date: Tue, 18 Nov 2014 01:25:27 -0800
Message-ID: <1416302731-11327-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10813 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776AbaKRJZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 04:25:57 -0500
In-Reply-To: <1416302731-11327-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

When the port TC configuration changes as a result of DCBx the driver
modifies the enabled TCs for the VEBs it manages. But, in the process
it did not update the enabled_tc value that it caches on a per VEB basis.

So, when the next reconfiguration event occurs where the number of TC
value is same as the value cached in enabled_tc for a given VEB; driver
does not modify it's TC configuration by calling appropriate AQ command
believing it is running with the same configuration as requested.
Now, as the VEB is not actually enabled for the TCs that are there any
TC configuration command for VSI attached to that VEB with TCs that are
not enabled for the VEB fails.

This patch fixes this issue.

Change-ID: Ife5694469b05494228e0d850429ea1734738cf29
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Tested-By: Jack Morgan <jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 99b985c..71ab327 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8279,6 +8279,7 @@ static int i40e_veb_get_bw_info(struct i40e_veb *veb)
 	veb->bw_limit = le16_to_cpu(ets_data.port_bw_limit);
 	veb->bw_max_quanta = ets_data.tc_bw_max;
 	veb->is_abs_credits = bw_data.absolute_credits_enable;
+	veb->enabled_tc = ets_data.tc_valid_bits;
 	tc_bw_max = le16_to_cpu(bw_data.tc_bw_max[0]) |
 		    (le16_to_cpu(bw_data.tc_bw_max[1]) << 16);
 	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
-- 
1.9.3
