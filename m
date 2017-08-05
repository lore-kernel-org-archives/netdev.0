From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/15] mlxsw: spectrum: rename cls arg in matchall processing
Date: Sat,  5 Aug 2017 16:53:31 +0200
Message-ID: <20170805145337.17728-10-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36430 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752465AbdHEOxy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:53:54 -0400
Received: by mail-wm0-f68.google.com with SMTP id d40so8766901wma.3
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:53:54 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

To sync-up with the naming in the rest of the driver, rename the cls arg.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9f8ba37..f333d08 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1618,7 +1618,7 @@ mlxsw_sp_port_del_cls_matchall_sample(struct mlxsw_sp_port *mlxsw_sp_port)
 
 static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  __be16 protocol,
-					  struct tc_cls_matchall_offload *cls,
+					  struct tc_cls_matchall_offload *f,
 					  bool ingress)
 {
 	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
@@ -1626,7 +1626,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	LIST_HEAD(actions);
 	int err;
 
-	if (!tcf_exts_has_one_action(cls->exts)) {
+	if (!tcf_exts_has_one_action(f->exts)) {
 		netdev_err(mlxsw_sp_port->dev, "only singular actions are supported\n");
 		return -EOPNOTSUPP;
 	}
@@ -1634,9 +1634,9 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
 	if (!mall_tc_entry)
 		return -ENOMEM;
-	mall_tc_entry->cookie = cls->cookie;
+	mall_tc_entry->cookie = f->cookie;
 
-	tcf_exts_to_list(cls->exts, &actions);
+	tcf_exts_to_list(f->exts, &actions);
 	a = list_first_entry(&actions, struct tc_action, list);
 
 	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
@@ -1648,7 +1648,7 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 							    mirror, a, ingress);
 	} else if (is_tcf_sample(a) && protocol == htons(ETH_P_ALL)) {
 		mall_tc_entry->type = MLXSW_SP_PORT_MALL_SAMPLE;
-		err = mlxsw_sp_port_add_cls_matchall_sample(mlxsw_sp_port, cls,
+		err = mlxsw_sp_port_add_cls_matchall_sample(mlxsw_sp_port, f,
 							    a, ingress);
 	} else {
 		err = -EOPNOTSUPP;
@@ -1666,12 +1666,12 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
-					   struct tc_cls_matchall_offload *cls)
+					   struct tc_cls_matchall_offload *f)
 {
 	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
 
 	mall_tc_entry = mlxsw_sp_port_mall_tc_entry_find(mlxsw_sp_port,
-							 cls->cookie);
+							 f->cookie);
 	if (!mall_tc_entry) {
 		netdev_dbg(mlxsw_sp_port->dev, "tc entry not found on port\n");
 		return;
-- 
2.9.3
