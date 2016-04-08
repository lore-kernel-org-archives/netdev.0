From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] ixgbe: Change the lan_id and func fields to a u8 to avoid casts
Date: Thu,  7 Apr 2016 20:20:57 -0700
Message-ID: <1460085673-87056-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9519 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754042AbcDHDVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 23:21:17 -0400
In-Reply-To: <1460085673-87056-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Since the lan_id and func fields only ever hold small values, make
them u8 to avoid casts used to silence warnings.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c   | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 8c7e78b..dfdb114 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3600,7 +3600,7 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
 	fw_cmd.hdr.cmd = FW_CEM_CMD_DRIVER_INFO;
 	fw_cmd.hdr.buf_len = FW_CEM_CMD_DRIVER_INFO_LEN;
 	fw_cmd.hdr.cmd_or_resp.cmd_resv = FW_CEM_CMD_RESERVED;
-	fw_cmd.port_num = (u8)hw->bus.func;
+	fw_cmd.port_num = hw->bus.func;
 	fw_cmd.ver_maj = maj;
 	fw_cmd.ver_min = min;
 	fw_cmd.ver_build = build;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index d02a0a3..7ae4bbd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3122,8 +3122,8 @@ struct ixgbe_bus_info {
 	enum ixgbe_bus_width width;
 	enum ixgbe_bus_type type;
 
-	u16 func;
-	u16 lan_id;
+	u8 func;
+	u8 lan_id;
 };
 
 /* Flow control parameters */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 9d3f765..5affac1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -862,7 +862,7 @@ static void ixgbe_disable_rx_x550(struct ixgbe_hw *hw)
 		fw_cmd.hdr.cmd = FW_DISABLE_RXEN_CMD;
 		fw_cmd.hdr.buf_len = FW_DISABLE_RXEN_LEN;
 		fw_cmd.hdr.checksum = FW_DEFAULT_CHECKSUM;
-		fw_cmd.port_number = (u8)hw->bus.lan_id;
+		fw_cmd.port_number = hw->bus.lan_id;
 
 		status = ixgbe_host_interface_command(hw, (u32 *)&fw_cmd,
 					sizeof(struct ixgbe_hic_disable_rxen),
-- 
2.5.5
