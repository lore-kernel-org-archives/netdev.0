From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: remove unnecessary string copy operations
Date: Thu, 15 Oct 2015 02:40:01 -0700
Message-ID: <1444902004-14433-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbbJOJmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:32 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Save a little stack space and remove unnecessary strncpy() with a little
string pointer.

Change-ID: Id2719d34710bfc273d3bb445fec085cd04276e88
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2217078..e090c9c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4844,8 +4844,8 @@ out:
  */
 void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 {
-	char speed[SPEED_SIZE] = "Unknown";
-	char fc[FC_SIZE] = "RX/TX";
+	char *speed = "Unknown";
+	char *fc = "Unknown";
 
 	if (vsi->current_isup == isup)
 		return;
@@ -4866,19 +4866,19 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 
 	switch (vsi->back->hw.phy.link_info.link_speed) {
 	case I40E_LINK_SPEED_40GB:
-		strlcpy(speed, "40 Gbps", SPEED_SIZE);
+		speed = "40 G";
 		break;
 	case I40E_LINK_SPEED_20GB:
-		strncpy(speed, "20 Gbps", SPEED_SIZE);
+		speed = "20 G";
 		break;
 	case I40E_LINK_SPEED_10GB:
-		strlcpy(speed, "10 Gbps", SPEED_SIZE);
+		speed = "10 G";
 		break;
 	case I40E_LINK_SPEED_1GB:
-		strlcpy(speed, "1000 Mbps", SPEED_SIZE);
+		speed = "1000 M";
 		break;
 	case I40E_LINK_SPEED_100MB:
-		strncpy(speed, "100 Mbps", SPEED_SIZE);
+		speed = "100 M";
 		break;
 	default:
 		break;
@@ -4886,20 +4886,20 @@ void i40e_print_link_message(struct i40e_vsi *vsi, bool isup)
 
 	switch (vsi->back->hw.fc.current_mode) {
 	case I40E_FC_FULL:
-		strlcpy(fc, "RX/TX", FC_SIZE);
+		fc = "RX/TX";
 		break;
 	case I40E_FC_TX_PAUSE:
-		strlcpy(fc, "TX", FC_SIZE);
+		fc = "TX";
 		break;
 	case I40E_FC_RX_PAUSE:
-		strlcpy(fc, "RX", FC_SIZE);
+		fc = "RX";
 		break;
 	default:
-		strlcpy(fc, "None", FC_SIZE);
+		fc = "None";
 		break;
 	}
 
-	netdev_info(vsi->netdev, "NIC Link is Up %s Full Duplex, Flow Control: %s\n",
+	netdev_info(vsi->netdev, "NIC Link is Up %sbps Full Duplex, Flow Control: %s\n",
 		    speed, fc);
 }
 
-- 
2.4.3
