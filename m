From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/6] mlxsw: spectrum_flower: Add support for ip tos
Date: Mon, 17 Jul 2017 14:07:31 +0200
Message-ID: <20170717120731.3875-7-jiri@resnulli.us>
References: <20170717120731.3875-1-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34489 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdGQMHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:07:46 -0400
Received: by mail-wm0-f68.google.com with SMTP id p204so22723202wmg.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:07:46 -0700 (PDT)
In-Reply-To: <20170717120731.3875-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Support offloading rules that match on ip tos.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 84fe33c..400ad40 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -235,6 +235,13 @@ static int mlxsw_sp_flower_parse_ip(struct mlxsw_sp *mlxsw_sp,
 					 f->mask);
 	mlxsw_sp_acl_rulei_keymask_u32(rulei, MLXSW_AFK_ELEMENT_IP_TTL_,
 				       key->ttl, mask->ttl);
+
+	mlxsw_sp_acl_rulei_keymask_u32(rulei, MLXSW_AFK_ELEMENT_IP_ECN,
+				       key->tos & 0x3, mask->tos & 0x3);
+
+	mlxsw_sp_acl_rulei_keymask_u32(rulei, MLXSW_AFK_ELEMENT_IP_DSCP,
+				       key->tos >> 6, mask->tos >> 6);
+
 	return 0;
 }
 
-- 
2.9.3
