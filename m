From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/18] mlxsw: spectrum_buffers: Remove eg pool 3 default init and CPU port TC binding to it
Date: Thu, 14 Apr 2016 18:19:20 +0200
Message-ID: <1460650770-19382-9-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36939 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964800AbcDNQTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:45 -0400
Received: by mail-wm0-f49.google.com with SMTP id n3so133911280wmn.0
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:44 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since there is no congestion control for CPU port traffic, we can change
the CPU port TC binding to pool 0 with min_buff and max_buff zeroed.
Remove initialization for pool egress pool 3 since it is no longer used
by dafault.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index b43f7d36e..dc57d77 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -205,8 +205,7 @@ static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_egress[] = {
 		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_EGRESS_SIZE)),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
-		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_EGRESS_SIZE)),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 };
 
 #define MLXSW_SP_SB_PRS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_prs_egress)
@@ -289,7 +288,7 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_egress[] = {
 
 #define MLXSW_SP_SB_CMS_EGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms_egress)
 
-#define MLXSW_SP_CPU_PORT_SB_CM MLXSW_SP_SB_CM(104, 2, 3)
+#define MLXSW_SP_CPU_PORT_SB_CM MLXSW_SP_SB_CM(0, 0, 0)
 
 static const struct mlxsw_sp_sb_cm mlxsw_sp_cpu_port_sb_cms[] = {
 	MLXSW_SP_CPU_PORT_SB_CM,
-- 
2.5.5
