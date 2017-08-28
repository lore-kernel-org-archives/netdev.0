From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Store the requested FEC information
Date: Sun, 27 Aug 2017 17:15:50 -0700
Message-ID: <20170828001603.75876-3-jeffrey.t.kirsher@intel.com>
References: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Cc: Mariusz Stachura <mariusz.stachura@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55214 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751639AbdH1AQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 20:16:18 -0400
In-Reply-To: <20170828001603.75876-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mariusz Stachura <mariusz.stachura@intel.com>

Store information about FEC modes, that were requested. It will be used
in printing link status information function and this way there is no
need to call admin queue there.

Signed-off-by: Mariusz Stachura <mariusz.stachura@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 4 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 1 +
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8e082a946411..5c36a18a31be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2529,6 +2529,10 @@ i40e_status i40e_update_link_info(struct i40e_hw *hw)
 		if (status)
 			return status;
 
+		hw->phy.link_info.req_fec_info =
+			abilities.fec_cfg_curr_mod_ext_info &
+			(I40E_AQ_REQUEST_FEC_KR | I40E_AQ_REQUEST_FEC_RS);
+
 		memcpy(hw->phy.link_info.module_type, &abilities.module_type,
 		       sizeof(hw->phy.link_info.module_type));
 	}
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 3a18ed13edc4..fd4bbdd88b57 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -185,6 +185,7 @@ struct i40e_link_status {
 	enum i40e_aq_link_speed link_speed;
 	u8 link_info;
 	u8 an_info;
+	u8 req_fec_info;
 	u8 fec_info;
 	u8 ext_info;
 	u8 loopback;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index bde7f24af1c6..2ea919d9cdcf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -159,6 +159,7 @@ struct i40e_link_status {
 	enum i40e_aq_link_speed link_speed;
 	u8 link_info;
 	u8 an_info;
+	u8 req_fec_info;
 	u8 fec_info;
 	u8 ext_info;
 	u8 loopback;
-- 
2.14.1
