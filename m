From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/7] mlxsw: Use correct skb length when dumping payload
Date: Thu,  6 Aug 2015 16:41:57 +0200
Message-ID: <1438872118-16869-7-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38262 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbHFOmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:17 -0400
Received: by wibxm9 with SMTP id xm9so27419416wib.1
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:16 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Do not use the length of the transmitted skb (which was freed), but
that of the response skb.

This issue was discovered using the Kernel Address sanitizer (KASan).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 7562802..09325b7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1073,7 +1073,7 @@ static int mlxsw_core_reg_access_emad(struct mlxsw_core *mlxsw_core,
 			mlxsw_core->emad.tid - 1);
 		mlxsw_core_buf_dump_dbg(mlxsw_core,
 					mlxsw_core->emad.resp_skb->data,
-					skb->len);
+					mlxsw_core->emad.resp_skb->len);
 
 		dev_kfree_skb(mlxsw_core->emad.resp_skb);
 	}
-- 
1.9.3
