From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Fix MAC format in Write MAC address AQ cmd
Date: Thu,  9 Jan 2014 04:52:13 -0800
Message-ID: <1389271944-26227-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44616 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897AbaAIMw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:29 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

The MAC address format expected by the hardware is in a very specific
format, and the driver was filling in the data incorrectly.

Change-ID: I7bc66505ef459ee347dd3bda68051004c141c689
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 8f28aee..807312b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -254,8 +254,11 @@ i40e_status i40e_aq_mac_address_write(struct i40e_hw *hw,
 	i40e_fill_default_direct_cmd_desc(&desc,
 					  i40e_aqc_opc_mac_address_write);
 	cmd_data->command_flags = cpu_to_le16(flags);
-	memcpy(&cmd_data->mac_sal, &mac_addr[0], 4);
-	memcpy(&cmd_data->mac_sah, &mac_addr[4], 2);
+	cmd_data->mac_sah = cpu_to_le16((u16)mac_addr[0] << 8 | mac_addr[1]);
+	cmd_data->mac_sal = cpu_to_le32(((u32)mac_addr[2] << 24) |
+					((u32)mac_addr[3] << 16) |
+					((u32)mac_addr[4] << 8) |
+					mac_addr[5]);
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
-- 
1.8.3.1
