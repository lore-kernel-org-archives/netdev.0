From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 3/5] mlxsw: acl: Add tcp flags acl element
Date: Tue, 23 May 2017 18:40:46 +0200
Message-ID: <20170523164048.16514-4-jiri@resnulli.us>
References: <20170523164048.16514-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        simon.horman@netronome.com, mlxsw@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36055 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764433AbdEWQlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 12:41:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id k15so39524296wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 09:40:59 -0700 (PDT)
In-Reply-To: <20170523164048.16514-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Define new element for tcp flags and place it into scratch area.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c    | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
index c75e914..9807ef8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
@@ -56,6 +56,7 @@ enum mlxsw_afk_element {
 	MLXSW_AFK_ELEMENT_SRC_L4_PORT,
 	MLXSW_AFK_ELEMENT_VID,
 	MLXSW_AFK_ELEMENT_PCP,
+	MLXSW_AFK_ELEMENT_TCP_FLAGS,
 	MLXSW_AFK_ELEMENT_MAX,
 };
 
@@ -102,6 +103,7 @@ static const struct mlxsw_afk_element_info mlxsw_afk_element_infos[] = {
 	MLXSW_AFK_ELEMENT_INFO_U32(IP_PROTO, 0x10, 0, 8),
 	MLXSW_AFK_ELEMENT_INFO_U32(VID, 0x10, 8, 12),
 	MLXSW_AFK_ELEMENT_INFO_U32(PCP, 0x10, 20, 3),
+	MLXSW_AFK_ELEMENT_INFO_U32(TCP_FLAGS, 0x10, 23, 9),
 	MLXSW_AFK_ELEMENT_INFO_U32(SRC_IP4, 0x18, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_U32(DST_IP4, 0x1C, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_BUF(SRC_IP6_HI, 0x18, 8),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index cc99de0..f7a8c3c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -198,6 +198,7 @@ static int mlxsw_sp_flower_parse(struct mlxsw_sp *mlxsw_sp,
 	      BIT(FLOW_DISSECTOR_KEY_IPV4_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_IPV6_ADDRS) |
 	      BIT(FLOW_DISSECTOR_KEY_PORTS) |
+	      BIT(FLOW_DISSECTOR_KEY_TCP) |
 	      BIT(FLOW_DISSECTOR_KEY_VLAN))) {
 		dev_err(mlxsw_sp->bus_info->dev, "Unsupported key\n");
 		return -EOPNOTSUPP;
-- 
2.9.3
