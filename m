From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/6] spectrum_flower: Implement gact trap TC action offload
Date: Tue,  6 Jun 2017 14:12:07 +0200
Message-ID: <20170606121207.2921-7-jiri@resnulli.us>
References: <20170606121207.2921-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        edumazet@google.com, alexander.h.duyck@intel.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        mlxsw@mellanox.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33383 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdFFMMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:12:23 -0400
Received: by mail-wr0-f194.google.com with SMTP id v104so10152065wrb.0
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 05:12:22 -0700 (PDT)
In-Reply-To: <20170606121207.2921-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Just use the previously prepared infrastructure and offload the gact
trap action to ACL.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 13af8e3..21bb2bf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -67,6 +67,10 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 			err = mlxsw_sp_acl_rulei_act_drop(rulei);
 			if (err)
 				return err;
+		} else if (is_tcf_gact_trap(a)) {
+			err = mlxsw_sp_acl_rulei_act_trap(rulei);
+			if (err)
+				return err;
 		} else if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
-- 
2.9.3
