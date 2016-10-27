From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Set physical device for port netdevice
Date: Thu, 27 Oct 2016 15:13:00 +0200
Message-ID: <1477573981-26546-5-git-send-email-jiri@resnulli.us>
References: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34268 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936467AbcJ0OUm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:20:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id y138so2951462wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 07:19:24 -0700 (PDT)
In-Reply-To: <1477573981-26546-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Do this so the sysfs has "device" link correctly set.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7805240..d652f7f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2222,6 +2222,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	dev = alloc_etherdev(sizeof(struct mlxsw_sp_port));
 	if (!dev)
 		return -ENOMEM;
+	SET_NETDEV_DEV(dev, mlxsw_sp->bus_info->dev);
 	mlxsw_sp_port = netdev_priv(dev);
 	mlxsw_sp_port->dev = dev;
 	mlxsw_sp_port->mlxsw_sp = mlxsw_sp;
-- 
2.5.5
