From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum_dpipe: Fix incorrect entry index
Date: Thu, 18 May 2017 09:18:52 +0200
Message-ID: <20170518071853.12279-2-jiri@resnulli.us>
References: <20170518071853.12279-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34432 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755106AbdERHTD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 03:19:03 -0400
Received: by mail-wr0-f195.google.com with SMTP id 6so4780943wrb.1
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 00:18:57 -0700 (PDT)
In-Reply-To: <20170518071853.12279-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

In case of disabled counters the entry index will be incorrect. Fix this
by moving the entry index set before the counter status check.

Fixes: 2ba5999f009d ("mlxsw: spectrum: Add Support for erif table entries access")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index ea56f6a..5f0a7bc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -199,10 +199,11 @@ static int mlxsw_sp_erif_entry_get(struct mlxsw_sp *mlxsw_sp,
 
 	entry->counter_valid = false;
 	entry->counter = 0;
+	entry->index = mlxsw_sp_rif_index(rif);
+
 	if (!counters_enabled)
 		return 0;
 
-	entry->index = mlxsw_sp_rif_index(rif);
 	err = mlxsw_sp_rif_counter_value_get(mlxsw_sp, rif,
 					     MLXSW_SP_RIF_COUNTER_EGRESS,
 					     &cnt);
-- 
2.9.3
