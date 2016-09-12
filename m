From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum: Report port type according to operational speed
Date: Mon, 12 Sep 2016 13:26:25 +0200
Message-ID: <1473679587-9112-4-git-send-email-jiri@resnulli.us>
References: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33442 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753421AbcILL0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 07:26:34 -0400
Received: by mail-wm0-f66.google.com with SMTP id b187so13136458wme.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 04:26:33 -0700 (PDT)
In-Reply-To: <1473679587-9112-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case port isn't operational we shouldn't report the port type, but
instead return PORT_OTHER. This is consistent with most other drivers
that return PORT_OTHER when media type can't be determined.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e035a9d..49b8d69 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1827,7 +1827,6 @@ static int mlxsw_sp_port_get_settings(struct net_device *dev,
 	mlxsw_sp_from_ptys_speed_duplex(netif_carrier_ok(dev),
 					eth_proto_oper, cmd);
 
-	eth_proto_oper = eth_proto_oper ? eth_proto_oper : eth_proto_cap;
 	cmd->port = mlxsw_sp_port_connector_port(eth_proto_oper);
 
 	if (autoneg_status == MLXSW_REG_PTYS_AN_STATUS_OK && eth_proto_lp)
-- 
2.5.5
