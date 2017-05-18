From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: spectrum_router: Fix rif counter freeing routine
Date: Thu, 18 May 2017 09:18:53 +0200
Message-ID: <20170518071853.12279-3-jiri@resnulli.us>
References: <20170518071853.12279-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36286 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754247AbdERHS7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 03:18:59 -0400
Received: by mail-wr0-f194.google.com with SMTP id v42so4779613wrc.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 00:18:58 -0700 (PDT)
In-Reply-To: <20170518071853.12279-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

During rif counter freeing the counter index can be invalid. Add check
of validity before freeing the counter.

Fixes: e0c0afd8aa4e ("mlxsw: spectrum: Support for counters on router interfaces")
Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 33cec1c..9f89c41 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -206,6 +206,9 @@ void mlxsw_sp_rif_counter_free(struct mlxsw_sp *mlxsw_sp,
 {
 	unsigned int *p_counter_index;
 
+	if (!mlxsw_sp_rif_counter_valid_get(rif, dir))
+		return;
+
 	p_counter_index = mlxsw_sp_rif_p_counter_get(rif, dir);
 	if (WARN_ON(!p_counter_index))
 		return;
-- 
2.9.3
