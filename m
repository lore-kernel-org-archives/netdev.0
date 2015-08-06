From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] mlxsw: Call free_netdev when removing port
Date: Thu,  6 Aug 2015 16:41:52 +0200
Message-ID: <1438872118-16869-2-git-send-email-jiri@resnulli.us>
References: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37071 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754755AbbHFOmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 10:42:04 -0400
Received: by wibhh20 with SMTP id hh20so27389393wib.0
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 07:42:03 -0700 (PDT)
In-Reply-To: <1438872118-16869-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a port's netdevice we should also free the memory
allocated by alloc_etherdev(). Do this by calling free_netdev() at the
end of the teardown sequence.

Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 29b46ee..687f5cb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1079,6 +1079,7 @@ static void mlxsw_sx_port_remove(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	unregister_netdev(mlxsw_sx_port->dev); /* This calls ndo_stop */
 	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	free_percpu(mlxsw_sx_port->pcpu_stats);
+	free_netdev(mlxsw_sx_port->dev);
 }
 
 static void mlxsw_sx_ports_remove(struct mlxsw_sx *mlxsw_sx)
-- 
1.9.3
