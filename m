From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/4] mlxsw: switchx2: Fix ethernet port initialization
Date: Thu, 20 Oct 2016 16:05:44 +0200
Message-ID: <1476972345-31568-4-git-send-email-jiri@resnulli.us>
References: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33697 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754657AbcJTOFy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 10:05:54 -0400
Received: by mail-lf0-f67.google.com with SMTP id l131so174587lfl.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 07:05:53 -0700 (PDT)
In-Reply-To: <1476972345-31568-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

When creating an ethernet port fails, we must move the port to disable,
otherwise putting the port in switch partition 0 (ETH) or 1 (IB) will
always fails.

Fixes: 31557f0f9755 ("mlxsw: Introduce Mellanox SwitchX-2 ASIC support")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index c0c23e2..92bda87 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1088,6 +1088,7 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 err_port_admin_status_set:
 err_port_mtu_set:
 err_port_speed_set:
+	mlxsw_sx_port_swid_set(mlxsw_sx_port, MLXSW_PORT_SWID_DISABLED_PORT);
 err_port_swid_set:
 err_port_system_port_mapping_set:
 port_not_usable:
-- 
2.5.5
