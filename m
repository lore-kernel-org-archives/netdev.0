From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] mlxsw: spectrum_flower: Offload "ok" termination action
Date: Mon, 25 Sep 2017 10:58:22 +0200
Message-ID: <20170925085822.1358-4-jiri@resnulli.us>
References: <20170925085822.1358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36724 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932107AbdIYI61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:58:27 -0400
Received: by mail-wm0-f68.google.com with SMTP id r136so6536858wmf.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:58:26 -0700 (PDT)
In-Reply-To: <20170925085822.1358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

If action is "gact_ok", offload it to HW.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index f1cedcc..2f0e578 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -63,7 +63,11 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 
 	tcf_exts_to_list(exts, &actions);
 	list_for_each_entry(a, &actions, list) {
-		if (is_tcf_gact_shot(a)) {
+		if (is_tcf_gact_ok(a)) {
+			err = mlxsw_sp_acl_rulei_act_continue(rulei);
+			if (err)
+				return err;
+		} else if (is_tcf_gact_shot(a)) {
 			err = mlxsw_sp_acl_rulei_act_drop(rulei);
 			if (err)
 				return err;
-- 
2.9.5
