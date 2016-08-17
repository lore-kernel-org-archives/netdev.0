From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 09/10] mlxsw: spectrum: Unmap 802.1Q FID before destroying it
Date: Wed, 17 Aug 2016 16:39:36 +0200
Message-ID: <1471444777-3412-10-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35880 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbcHQOjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so24727881wmf.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:53 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Before destroying the 802.1Q FID we should first remove the VID-to-FID
mapping. This makes mlxsw_sp_fid_destroy() symmetric with regards to
mlxsw_sp_fid_create().

Fixes: 14d39461b3f4 ("mlxsw: spectrum: Use per-FID struct for the VLAN-aware bridge")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index b5e864d..d1b59cd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -450,6 +450,8 @@ void mlxsw_sp_fid_destroy(struct mlxsw_sp *mlxsw_sp, struct mlxsw_sp_fid *f)
 
 	kfree(f);
 
+	mlxsw_sp_fid_map(mlxsw_sp, fid, false);
+
 	mlxsw_sp_fid_op(mlxsw_sp, fid, false);
 }
 
-- 
2.5.5
