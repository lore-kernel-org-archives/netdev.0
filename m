From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/6] mlxsw: spectrum: Introduce ACL trap
Date: Tue,  6 Jun 2017 14:12:05 +0200
Message-ID: <20170606121207.2921-5-jiri@resnulli.us>
References: <20170606121207.2921-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36237 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdFFMMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:12:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id k15so34616065wmh.3
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 05:12:18 -0700 (PDT)
In-Reply-To: <20170606121207.2921-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce an ACL trap and put it into ip2me trap group.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 +++-
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 84b6f36..f60e2ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3261,7 +3261,9 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
 	/* PKT Sample trap */
 	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
-		  false, SP_IP2ME, DISCARD)
+		  false, SP_IP2ME, DISCARD),
+	/* ACL trap */
+	MLXSW_SP_RXL_NO_MARK(ACL0, TRAP_TO_CPU, IP2ME, false),
 };
 
 static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index e008fdb..12b5ed5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -66,6 +66,7 @@ enum {
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
 	MLXSW_TRAP_ID_BGP_IPV4 = 0x88,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
+	MLXSW_TRAP_ID_ACL0 = 0x1C0,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
 };
-- 
2.9.3
