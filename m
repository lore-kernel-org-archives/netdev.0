From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: switchx2: Set physical device for port netdevice
Date: Thu, 27 Oct 2016 15:13:01 +0200
Message-ID: <1477573981-26546-6-git-send-email-jiri@resnulli.us>
References: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34102 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965958AbcJ0OVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:21:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id y138so2960836wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:21:31 -0700 (PDT)
In-Reply-To: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do this so the sysfs has "device" link correctly set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 938e22d..dc3c5ed 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -968,6 +968,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	dev = alloc_etherdev(sizeof(struct mlxsw_sx_port));
 	if (!dev)
 		return -ENOMEM;
+	SET_NETDEV_DEV(dev, mlxsw_sx->bus_info->dev);
 	mlxsw_sx_port = netdev_priv(dev);
 	mlxsw_sx_port->dev = dev;
 	mlxsw_sx_port->mlxsw_sx = mlxsw_sx;
-- 
2.5.5
