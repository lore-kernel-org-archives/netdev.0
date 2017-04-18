From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: spectrum_flower: Set dummy FID before forward action
Date: Tue, 18 Apr 2017 16:55:34 +0200
Message-ID: <1492527338-13298-5-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36024 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754824AbdDROzr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id q125so15241673wmd.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:46 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

HW requires the FID to be valid in order for the forward action to work.
So regardless of the current FID validity, just set the dummy FID which
would do the trick.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 3e7a0bc..7d87e23 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -71,6 +71,11 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
 
+			err = mlxsw_sp_acl_rulei_act_fid_set(mlxsw_sp, rulei,
+							     MLXSW_SP_DUMMY_FID);
+			if (err)
+				return err;
+
 			out_dev = __dev_get_by_index(dev_net(dev), ifindex);
 			if (out_dev == dev)
 				out_dev = NULL;
-- 
2.7.4
