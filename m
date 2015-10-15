From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/15] mlxsw: core: Do not use EMADs in mlxsw_emad_fini
Date: Thu, 15 Oct 2015 17:43:21 +0200
Message-ID: <1444923809-20785-8-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33894 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbbJOPnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:41 -0400
Received: by lfaz124 with SMTP id z124so33138718lfa.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:40 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be symmetric with mlxsw_emad_init and don't use EMADs in mlxsw_emad_fini
cleanup function. Use command interface instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 28c19cc..cf7c9d2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -556,6 +556,7 @@ static void mlxsw_emad_fini(struct mlxsw_core *mlxsw_core)
 {
 	char hpkt_pl[MLXSW_REG_HPKT_LEN];
 
+	mlxsw_core->emad.use_emad = false;
 	mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_DISCARD,
 			    MLXSW_REG_HTGT_TRAP_GROUP_EMAD,
 			    MLXSW_TRAP_ID_ETHEMAD);
-- 
1.9.3
