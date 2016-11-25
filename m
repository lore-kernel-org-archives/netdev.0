From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/19] mlxsw: spectrum: Remove unused traps
Date: Fri, 25 Nov 2016 10:33:29 +0100
Message-ID: <1480066427-3961-2-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36787 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id m203so7188101wma.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:51 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Since commit 99724c18fc66 ("mlxsw: spectrum: Introduce support for
router interfaces") we no longer rely on flooding traffic to the CPU in
order to trap packets intended for the host itself. Therefore, the FDB
MC trap can be removed.
Remove traps for protocols that are not supported yet.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e0d7d5a..2f06de3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2785,15 +2785,10 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	}
 
 static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, FDB_MC, TRAP_TO_CPU),
-	/* Traps for specific L2 packet types, not trapped as FDB MC */
+	/* L2 traps */
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, EAPOL, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LLDP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MMRP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MVRP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RPVST, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, DHCP, MIRROR_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, IGMP_QUERY, MIRROR_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT, TRAP_TO_CPU),
-- 
2.7.4
