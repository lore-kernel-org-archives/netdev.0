From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/15] i40e: Add warning for NPAR partitions with link speed less than 10Gbps
Date: Tue, 13 Jan 2015 11:58:07 -0800
Message-ID: <1421179093-10932-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41216 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858AbbAMT6S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:18 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

NPAR enabled partitions should warn the user when detected link speed is
less than 10Gpbs.

Change-ID: I7728bb8ce279bf0f4f755d78d7071074a4eb5f69
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a5f2660..7c14973 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4557,6 +4557,15 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 		return;
 	}
 
+	/* Warn user if link speed on NPAR enabled partition is not at
+	 * least 10GB
+	 */
+	if (vsi->back->hw.func_caps.npar_enable &&
+	    (vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_1GB ||
+	     vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_100MB))
+		netdev_warn(vsi->netdev,
+			    "The partition detected link speed that is less than 10Gbps\n");
+
 	switch (vsi->back->hw.phy.link_info.link_speed) {
 	case I40E_LINK_SPEED_40GB:
 		strlcpy(speed, "40 Gbps", SPEED_SIZE);
-- 
1.9.3
