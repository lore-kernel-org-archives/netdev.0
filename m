From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 09/12] mlxsw: spectrum: router: Squash the default route table to main
Date: Wed, 27 Sep 2017 08:23:19 +0200
Message-ID: <20170927062322.5476-10-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35502 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751811AbdI0GXe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:34 -0400
Received: by mail-wr0-f195.google.com with SMTP id n64so3581615wrb.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:34 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
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
index 321f735..28c0c84 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -693,8 +693,8 @@ static int mlxsw_sp_vr_lpm_tree_unbind(struct mlxsw_sp *mlxsw_sp,
 
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
