From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/12] mlxsw: spectrum: router: Squash the default route table to main
Date: Sun, 24 Sep 2017 19:22:09 +0200
Message-ID: <20170924172212.10096-10-jiri@resnulli.us>
References: <20170924172212.10096-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37266 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbdIXRWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 13:22:24 -0400
Received: by mail-wm0-f67.google.com with SMTP id f4so5304368wmh.4
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 10:22:23 -0700 (PDT)
In-Reply-To: <20170924172212.10096-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Currently, the mlxsw Spectrum driver offloads only either the RT_TABLE_MAIN
FIB table or the VRF tables, so the RT_TABLE_LOCAL table is squashed to the
RT_TABLE_MAIN table to allow local routes to be offloaded too.

By default, multicast MFC routes which are not assigned to any user
requested table are put in the RT_TABLE_DEFAULT table.

Due to the fact that offloading multicast MFC routes support in Spectrum
router logic is going to be introduced soon, squash the default table to
MAIN too.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 0bd93dc..1e6122f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -692,8 +692,8 @@ static int mlxsw_sp_vr_lpm_tree_unbind(struct mlxsw_sp *mlxsw_sp,
 
 static u32 mlxsw_sp_fix_tb_id(u32 tb_id)
 {
-	/* For our purpose, squash main and local table into one */
-	if (tb_id == RT_TABLE_LOCAL)
+	/* For our purpose, squash main, default and local tables into one */
+	if (tb_id == RT_TABLE_LOCAL || tb_id == RT_TABLE_DEFAULT)
 		tb_id = RT_TABLE_MAIN;
 	return tb_id;
 }
-- 
2.9.5
