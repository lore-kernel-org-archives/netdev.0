From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: simplify member variable accesses
Date: Fri, 29 Sep 2017 17:44:56 -0700
Message-ID: <20170930004507.20072-5-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:57175 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752672AbdI3Apw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:52 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

This commit replaces usage of vsi->back in i40e_print_link_message()
(which is actually a PF pointer) with temp variable.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2e8fe6186b38..3c650917b54f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5346,13 +5346,14 @@ static int i40e_init_pf_dcb(struct i40e_pf *pf)
 void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 {
 	enum i40e_aq_link_speed new_speed;
+	struct i40e_pf *pf = vsi->back;
 	char *speed = "Unknown";
 	char *fc = "Unknown";
 	char *fec = "";
 	char *req_fec = "";
 	char *an = "";
 
-	new_speed = vsi->back->hw.phy.link_info.link_speed;
+	new_speed = pf->hw.phy.link_info.link_speed;
 
 	if ((vsi->current_isup == isup) && (vsi->current_speed == new_speed))
 		return;
@@ -5366,13 +5367,13 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 	/* Warn user if link speed on NPAR enabled partition is not at
 	 * least 10GB
 	 */
-	if (vsi->back->hw.func_caps.npar_enable &&
-	    (vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_1GB ||
-	     vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_100MB))
+	if (pf->hw.func_caps.npar_enable &&
+	    (pf->hw.phy.link_info.link_speed == I40E_LINK_SPEED_1GB ||
+	     pf->hw.phy.link_info.link_speed == I40E_LINK_SPEED_100MB))
 		netdev_warn(vsi->netdev,
 			    "The partition detected link speed that is less than 10Gbps\n");
 
-	switch (vsi->back->hw.phy.link_info.link_speed) {
+	switch (pf->hw.phy.link_info.link_speed) {
 	case I40E_LINK_SPEED_40GB:
 		speed = "40 G";
 		break;
@@ -5395,7 +5396,7 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 		break;
 	}
 
-	switch (vsi->back->hw.fc.current_mode) {
+	switch (pf->hw.fc.current_mode) {
 	case I40E_FC_FULL:
 		fc = "RX/TX";
 		break;
@@ -5410,18 +5411,18 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 		break;
 	}
 
-	if (vsi->back->hw.phy.link_info.link_speed == I40E_LINK_SPEED_25GB) {
+	if (pf->hw.phy.link_info.link_speed == I40E_LINK_SPEED_25GB) {
 		req_fec = ", Requested FEC: None";
 		fec = ", FEC: None";
 		an = ", Autoneg: False";
 
-		if (vsi->back->hw.phy.link_info.an_info & I40E_AQ_AN_COMPLETED)
+		if (pf->hw.phy.link_info.an_info & I40E_AQ_AN_COMPLETED)
 			an = ", Autoneg: True";
 
-		if (vsi->back->hw.phy.link_info.fec_info &
+		if (pf->hw.phy.link_info.fec_info &
 		    I40E_AQ_CONFIG_FEC_KR_ENA)
 			fec = ", FEC: CL74 FC-FEC/BASE-R";
-		else if (vsi->back->hw.phy.link_info.fec_info &
+		else if (pf->hw.phy.link_info.fec_info &
 			 I40E_AQ_CONFIG_FEC_RS_ENA)
 			fec = ", FEC: CL108 RS-FEC";
 
-- 
2.14.1
