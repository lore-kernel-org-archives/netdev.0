From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: core: Use correct EMAD transaction ID in debug message
Date: Wed,  2 Aug 2017 09:52:10 +0200
Message-ID: <20170802075210.1000-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35397 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdHBHwN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 03:52:13 -0400
Received: by mail-wr0-f196.google.com with SMTP id c24so3044852wra.2
        for <netdev@vger.kernel.org>; Wed, 02 Aug 2017 00:52:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

'trans->tid' is only assigned later in the function, resulting in a zero
transaction ID. Use 'tid' instead.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index affe84e..9d5e7cf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -667,7 +667,7 @@ static int mlxsw_emad_reg_access(struct mlxsw_core *mlxsw_core,
 	int err;
 
 	dev_dbg(mlxsw_core->bus_info->dev, "EMAD reg access (tid=%llx,reg_id=%x(%s),type=%s)\n",
-		trans->tid, reg->id, mlxsw_reg_id_str(reg->id),
+		tid, reg->id, mlxsw_reg_id_str(reg->id),
 		mlxsw_core_reg_access_type_str(type));
 
 	skb = mlxsw_emad_alloc(mlxsw_core, reg->len);
-- 
2.9.3
