From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/5] mlxsw: spectrum: Don't emit errors when PFC is disabled
Date: Fri, 15 Jul 2016 11:15:00 +0200
Message-ID: <1468574102-26288-4-git-send-email-jiri@resnulli.us>
References: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34911 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932473AbcGOJPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:09 -0400
Received: by mail-wm0-f65.google.com with SMTP id i5so1375612wmg.2
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:08 -0700 (PDT)
In-Reply-To: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We can't have PAUSE frames and PFC both enabled on the same port, but
the fact that ieee_setpfc() was called doesn't necessarily mean PFC is
enabled.

Only emit errors when PAUSE frames and PFC are enabled simultaneously.

Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 0b32366..5d4b1e7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -351,7 +351,8 @@ static int mlxsw_sp_dcbnl_ieee_setpfc(struct net_device *dev,
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	int err;
 
-	if (mlxsw_sp_port->link.tx_pause || mlxsw_sp_port->link.rx_pause) {
+	if ((mlxsw_sp_port->link.tx_pause || mlxsw_sp_port->link.rx_pause) &&
+	    pfc->pfc_en) {
 		netdev_err(dev, "PAUSE frames already enabled on port\n");
 		return -EINVAL;
 	}
-- 
2.5.5
