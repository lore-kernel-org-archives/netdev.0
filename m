From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum_router: Remove unused variable
Date: Mon,  6 Feb 2017 16:20:12 +0100
Message-ID: <1486394417-8011-4-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:33569 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdBFPUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:24 -0500
Received: by mail-wj0-f195.google.com with SMTP id le4so3364577wjb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:23 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Since commit 33b1341cd1bf ("mlxsw: spectrum_router: Fix handling of
neighbour structure") we no longer use destination IP for neighbour
lookup, so remove it.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 0d8201e..851799d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1004,7 +1004,6 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 	struct net_device *dev;
 	struct neigh_parms *p;
 	struct neighbour *n;
-	u32 dip;
 
 	switch (event) {
 	case NETEVENT_DELAY_PROBE_TIME_UPDATE:
@@ -1039,7 +1038,6 @@ int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 			return NOTIFY_DONE;
 
 		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
-		dip = ntohl(*((__be32 *) n->primary_key));
 		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, n);
 		if (WARN_ON(!neigh_entry)) {
 			mlxsw_sp_port_dev_put(mlxsw_sp_port);
-- 
2.7.4
