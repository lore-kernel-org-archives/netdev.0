From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/6] mlxsw: spectrum: Add tos to the ipv4 acl block
Date: Mon, 17 Jul 2017 14:07:30 +0200
Message-ID: <20170717120731.3875-6-jiri@resnulli.us>
References: <20170717120731.3875-1-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33358 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751466AbdGQMHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:07:44 -0400
Received: by mail-wr0-f193.google.com with SMTP id 40so2492328wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:07:44 -0700 (PDT)
In-Reply-To: <20170717120731.3875-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add ecn and dscp fields to the ipv4 acl block.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c      | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
index 8a4767c..fb80318 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_flex_keys.h
@@ -70,7 +70,9 @@ static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4_dip[] = {
 
 static struct mlxsw_afk_element_inst mlxsw_sp_afk_element_info_ipv4[] = {
 	MLXSW_AFK_ELEMENT_INST_U32(SRC_IP4, 0x00, 0, 32),
+	MLXSW_AFK_ELEMENT_INST_U32(IP_ECN, 0x04, 4, 2),
 	MLXSW_AFK_ELEMENT_INST_U32(IP_TTL_, 0x04, 24, 8),
+	MLXSW_AFK_ELEMENT_INST_U32(IP_DSCP, 0x08, 0, 6),
 	MLXSW_AFK_ELEMENT_INST_U32(TCP_FLAGS, 0x08, 8, 9), /* TCP_CONTROL+TCP_ECN */
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
index 2c57be7..bc5173f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl_tcam.c
@@ -985,6 +985,8 @@ static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv4[] = {
 	MLXSW_AFK_ELEMENT_PCP,
 	MLXSW_AFK_ELEMENT_TCP_FLAGS,
 	MLXSW_AFK_ELEMENT_IP_TTL_,
+	MLXSW_AFK_ELEMENT_IP_ECN,
+	MLXSW_AFK_ELEMENT_IP_DSCP,
 };
 
 static const enum mlxsw_afk_element mlxsw_sp_acl_tcam_pattern_ipv6[] = {
-- 
2.9.3
