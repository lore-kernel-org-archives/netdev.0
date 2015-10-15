From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/15] mlxsw: cmd: Update CONFIG_PROFILE command documentation
Date: Thu, 15 Oct 2015 17:43:29 +0200
Message-ID: <1444923809-20785-16-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35859 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511AbbJOPnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:51 -0400
Received: by lbcao8 with SMTP id ao8so73586250lbc.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:49 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The meaning of certain parameters in the profile passed to the device
during initialization has changed, so update their documentation
accordingly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index 27e48b4..c7889f4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -570,7 +570,7 @@ MLXSW_ITEM32(cmd_mbox, config_profile, set_max_vlan_groups, 0x0C, 6, 1);
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, set_max_regions, 0x0C, 7, 1);
 
-/* cmd_mbox_config_profile_set_fid_based
+/* cmd_mbox_config_profile_set_flood_mode
  * Capability bit. Setting a bit to 1 configures the profile
  * according to the mailbox contents.
  */
@@ -651,12 +651,8 @@ MLXSW_ITEM32(cmd_mbox, config_profile, max_vlan_groups, 0x28, 0, 12);
 MLXSW_ITEM32(cmd_mbox, config_profile, max_regions, 0x2C, 0, 16);
 
 /* cmd_mbox_config_profile_max_flood_tables
- * Maximum number of Flooding Tables. Flooding Tables are associated to
- * the different packet types for the different switch partitions.
- * Note that the table size depends on the fid_based mode.
- * In SwitchX silicon, tables are split equally between the switch
- * partitions. e.g. for 2 swids and 8 tables, the first 4 are associated
- * with swid-1 and the last 4 are associated with swid-2.
+ * Maximum number of single-entry flooding tables. Different flooding tables
+ * can be associated with different packet types.
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, max_flood_tables, 0x30, 16, 4);
 
@@ -667,12 +663,14 @@ MLXSW_ITEM32(cmd_mbox, config_profile, max_flood_tables, 0x30, 16, 4);
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, max_vid_flood_tables, 0x30, 8, 4);
 
-/* cmd_mbox_config_profile_fid_based
- * FID Based Flood Mode
- * 00 Do not use FID to offset the index into the Port Group Table/Multicast ID
- * 01 Use FID to offset the index to the Port Group Table (pgi)
- * 10 Use FID to offset the index to the Port Group Table (pgi) and
- * the Multicast ID
+/* cmd_mbox_config_profile_flood_mode
+ * Flooding mode to use.
+ * 0-2 - Backward compatible modes for SwitchX devices.
+ * 3 - Mixed mode, where:
+ * max_flood_tables indicates the number of single-entry tables.
+ * max_vid_flood_tables indicates the number of per-VID tables.
+ * max_fid_offset_flood_tables indicates the number of FID-offset tables.
+ * max_fid_flood_tables indicates the number of per-FID tables.
  */
 MLXSW_ITEM32(cmd_mbox, config_profile, flood_mode, 0x30, 0, 2);
 
-- 
1.9.3
