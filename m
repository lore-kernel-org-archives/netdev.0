From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/18] mlxsw: spectrum_buffers: Change initialization of PG 9
Date: Thu, 14 Apr 2016 18:19:21 +0200
Message-ID: <1460650770-19382-10-git-send-email-jiri@resnulli.us>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38625 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964802AbcDNQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 12:19:46 -0400
Received: by mail-wm0-f46.google.com with SMTP id u206so133452400wme.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 09:19:45 -0700 (PDT)
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As explained in commit ff6551ec0c27 ("mlxsw: spectrum: Correctly
configure headroom size") control packets are directed to priority group
buffer 9 (PG9) in the ports' headroom buffers.

Since we don't want to drop control packets in case they can't be
admitted to the switch's shared buffer we bind PG9 to a different
ingress pool from the one used by all other PGs.

Unlike other PGs, we currently don't expose the binding between PG9 to a
pool and leave it fixed.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index dc57d77..7ee2315 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -181,6 +181,7 @@ static int mlxsw_sp_port_headroom_init(struct mlxsw_sp_port *mlxsw_sp_port)
 
 #define MLXSW_SP_SB_PR_INGRESS_SIZE				\
 	(15000000 - (2 * 20000 * MLXSW_PORT_MAX_PORTS))
+#define MLXSW_SP_SB_PR_INGRESS_MNG_SIZE (200 * 1000)
 #define MLXSW_SP_SB_PR_EGRESS_SIZE				\
 	(14000000 - (8 * 1500 * MLXSW_PORT_MAX_PORTS))
 
@@ -195,7 +196,8 @@ static const struct mlxsw_sp_sb_pr mlxsw_sp_sb_prs_ingress[] = {
 		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_INGRESS_SIZE)),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
 	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
-	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC, 0),
+	MLXSW_SP_SB_PR(MLXSW_REG_SBPR_MODE_DYNAMIC,
+		       MLXSW_SP_BYTES_TO_CELLS(MLXSW_SP_SB_PR_INGRESS_MNG_SIZE)),
 };
 
 #define MLXSW_SP_SB_PRS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_prs_ingress)
@@ -261,7 +263,7 @@ static const struct mlxsw_sp_sb_cm mlxsw_sp_sb_cms_ingress[] = {
 	MLXSW_SP_SB_CM(0, 0, 0),
 	MLXSW_SP_SB_CM(0, 0, 0),
 	MLXSW_SP_SB_CM(0, 0, 0), /* dummy, this PG does not exist */
-	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(20000), 0xff, 0),
+	MLXSW_SP_SB_CM(MLXSW_SP_BYTES_TO_CELLS(20000), 1, 3),
 };
 
 #define MLXSW_SP_SB_CMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_cms_ingress)
@@ -386,7 +388,7 @@ static const struct mlxsw_sp_sb_pm mlxsw_sp_sb_pms_ingress[] = {
 	MLXSW_SP_SB_PM(0, 0xff),
 	MLXSW_SP_SB_PM(0, 0),
 	MLXSW_SP_SB_PM(0, 0),
-	MLXSW_SP_SB_PM(0, 0),
+	MLXSW_SP_SB_PM(0, 0xff),
 };
 
 #define MLXSW_SP_SB_PMS_INGRESS_LEN ARRAY_SIZE(mlxsw_sp_sb_pms_ingress)
-- 
2.5.5
