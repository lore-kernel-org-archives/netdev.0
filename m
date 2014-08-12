From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/6] i40e: Cleaning up missing null-terminate in conjunction with strncpy
Date: Tue, 12 Aug 2014 01:38:25 -0700
Message-ID: <1407832707-26034-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64307 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665AbaHLIig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 04:38:36 -0400
In-Reply-To: <1407832707-26034-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>

Replacing strncpy with strlcpy to avoid strings that lacks null terminate.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2ac8f45..871474f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4415,13 +4415,13 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 
 	switch (vsi->back->hw.phy.link_info.link_speed) {
 	case I40E_LINK_SPEED_40GB:
-		strncpy(speed, "40 Gbps", SPEED_SIZE);
+		strlcpy(speed, "40 Gbps", SPEED_SIZE);
 		break;
 	case I40E_LINK_SPEED_10GB:
-		strncpy(speed, "10 Gbps", SPEED_SIZE);
+		strlcpy(speed, "10 Gbps", SPEED_SIZE);
 		break;
 	case I40E_LINK_SPEED_1GB:
-		strncpy(speed, "1000 Mbps", SPEED_SIZE);
+		strlcpy(speed, "1000 Mbps", SPEED_SIZE);
 		break;
 	default:
 		break;
@@ -4429,16 +4429,16 @@ static void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 
 	switch (vsi->back->hw.fc.current_mode) {
 	case I40E_FC_FULL:
-		strncpy(fc, "RX/TX", FC_SIZE);
+		strlcpy(fc, "RX/TX", FC_SIZE);
 		break;
 	case I40E_FC_TX_PAUSE:
-		strncpy(fc, "TX", FC_SIZE);
+		strlcpy(fc, "TX", FC_SIZE);
 		break;
 	case I40E_FC_RX_PAUSE:
-		strncpy(fc, "RX", FC_SIZE);
+		strlcpy(fc, "RX", FC_SIZE);
 		break;
 	default:
-		strncpy(fc, "None", FC_SIZE);
+		strlcpy(fc, "None", FC_SIZE);
 		break;
 	}
 
@@ -5839,7 +5839,7 @@ static void i40e_send_version(struct i40e_pf *pf)
 	dv.minor_version = DRV_VERSION_MINOR;
 	dv.build_version = DRV_VERSION_BUILD;
 	dv.subbuild_version = 0;
-	strncpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
+	strlcpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
 	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
 }
 
-- 
1.9.3
