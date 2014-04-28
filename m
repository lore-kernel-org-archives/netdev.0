From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e/i40evf: Retrieve and store missing link config information
Date: Mon, 28 Apr 2014 06:52:37 -0700
Message-ID: <1398693158-2815-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <Neerav.Parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Neerav Parikh <neerav.parikh@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57319 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754049AbaD1Nwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:49 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <Neerav.Parikh@intel.com>

Some information returned via "Get Link Status" command was not
being cached in the struct i40e_link_status.
Add this so the driver can utilize this information as needed.

Change-ID: If084a0ae2a63b16b97572196b993742af2c67772
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 7 +++++++
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 3 +++
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 3 +++
 3 files changed, 13 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 55d029f..22eefda 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -975,6 +975,13 @@ i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
 	hw_link_info->an_info = resp->an_info;
 	hw_link_info->ext_info = resp->ext_info;
 	hw_link_info->loopback = resp->loopback;
+	hw_link_info->max_frame_size = le16_to_cpu(resp->max_frame_size);
+	hw_link_info->pacing = resp->config & I40E_AQ_CONFIG_PACING_MASK;
+
+	if (resp->config & I40E_AQ_CONFIG_CRC_ENA)
+		hw_link_info->crc_enable = true;
+	else
+		hw_link_info->crc_enable = false;
 
 	if (resp->command_flags & cpu_to_le16(I40E_AQ_LSE_ENABLE))
 		hw_link_info->lse_enable = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 668acc7..c4df8ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -167,6 +167,9 @@ struct i40e_link_status {
 	u8 loopback;
 	/* is Link Status Event notification to SW enabled */
 	bool lse_enable;
+	u16 max_frame_size;
+	bool crc_enable;
+	u8 pacing;
 };
 
 struct i40e_phy_info {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 449a3be..51a6dee 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -173,6 +173,9 @@ struct i40e_link_status {
 	u8 loopback;
 	/* is Link Status Event notification to SW enabled */
 	bool lse_enable;
+	u16 max_frame_size;
+	bool crc_enable;
+	u8 pacing;
 };
 
 struct i40e_phy_info {
-- 
1.9.0
