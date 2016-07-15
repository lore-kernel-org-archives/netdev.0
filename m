From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 4/5] mlxsw: spectrum: Prevent overwrite of DCB capability fields
Date: Fri, 15 Jul 2016 11:15:01 +0200
Message-ID: <1468574102-26288-5-git-send-email-jiri@resnulli.us>
References: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34334 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474AbcGOJPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 05:15:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so1382534wma.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 02:15:10 -0700 (PDT)
In-Reply-To: <1468574102-26288-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The number of supported traffic classes that can have ETS and PFC
simultaneously enabled is not subject to user configuration, so make
sure we always initialize them to the correct values following a set
operation.

Fixes: 8e8dfe9fdf06 ("mlxsw: spectrum: Add IEEE 802.1Qaz ETS support")
Fixes: d81a6bdb87ce ("mlxsw: spectrum: Add IEEE 802.1Qbb PFC support")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
index 5d4b1e7..4af3f27 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dcb.c
@@ -249,6 +249,7 @@ static int mlxsw_sp_dcbnl_ieee_setets(struct net_device *dev,
 		return err;
 
 	memcpy(mlxsw_sp_port->dcb.ets, ets, sizeof(*ets));
+	mlxsw_sp_port->dcb.ets->ets_cap = IEEE_8021QAZ_MAX_TCS;
 
 	return 0;
 }
@@ -372,6 +373,7 @@ static int mlxsw_sp_dcbnl_ieee_setpfc(struct net_device *dev,
 	}
 
 	memcpy(mlxsw_sp_port->dcb.pfc, pfc, sizeof(*pfc));
+	mlxsw_sp_port->dcb.pfc->pfc_cap = IEEE_8021QAZ_MAX_TCS;
 
 	return 0;
 
-- 
2.5.5
