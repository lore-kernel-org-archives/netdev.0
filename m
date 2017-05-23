From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/5] mlxsw: spectrum: Add acl block containing tcp flags for ipv4
Date: Tue, 23 May 2017 18:40:47 +0200
Message-ID: <20170523164048.16514-5-jiri@resnulli.us>
References: <20170523164048.16514-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32934 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759850AbdEWQk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:40:57 -0400
Received: by mail-wm0-f65.google.com with SMTP id b84so24909818wmh.0
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:40:57 -0700 (PDT)
In-Reply-To: <20170523164048.16514-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add acl block called "ipv4" which contains tcp flags.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
index af7b7ba..85d5001 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
@@ -68,6 +68,11 @@ static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_dip[] = {
 	MLXSW_AFK_ELEMENT_INST_U32(SRC_SYS_PORT, 0x0C, 0, 16),
 };
 
+static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4[] = {
+	MLXSW_AFK_ELEMENT_INST_U32(SRC_IP4, 0x00, 0, 32),
+	MLXSW_AFK_ELEMENT_INST_U32(TCP_FLAGS, 0x08, 8, 9), /* TCP_CONTROL+TCP_ECN */
+};
+
 static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_ex[] = {
 	MLXSW_AFK_ELEMENT_INST_U32(VID, 0x00, 0, 12),
 	MLXSW_AFK_ELEMENT_INST_U32(PCP, 0x08, 29, 3),
@@ -102,6 +107,7 @@ static const struct mlxsw_afk_block mlxsw_sp_afk_blocks[] = {
 	MLXSW_AFK_BLOCK(0x12, mlxsw_sp_afk_element_info_l2_smac_ex),
 	MLXSW_AFK_BLOCK(0x30, mlxsw_sp_afk_element_info_ipv4_sip),
 	MLXSW_AFK_BLOCK(0x31, mlxsw_sp_afk_element_info_ipv4_dip),
+	MLXSW_AFK_BLOCK(0x32, mlxsw_sp_afk_element_info_ipv4),
 	MLXSW_AFK_BLOCK(0x33, mlxsw_sp_afk_element_info_ipv4_ex),
 	MLXSW_AFK_BLOCK(0x60, mlxsw_sp_afk_element_info_ipv6_dip),
 	MLXSW_AFK_BLOCK(0x65, mlxsw_sp_afk_element_info_ipv6_ex1),
-- 
2.9.3
