From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] mlxsw: spectrum: Simplify traps definition
Date: Thu, 25 Aug 2016 18:42:38 +0200
Message-ID: <1472143360-15796-4-git-send-email-jiri@resnulli.us>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34267 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759450AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so8149753wma.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:47 -0700 (PDT)
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of copying & pasting the same struct initialization for every
Rx listener, just use a macro.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 146 ++++++-------------------
 1 file changed, 31 insertions(+), 115 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 2713a64..cc83cd2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2570,123 +2570,39 @@ static void mlxsw_sp_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	netif_receive_skb(skb);
 }
 
+#define MLXSW_SP_RXL(_func, _trap_id)			\
+	{						\
+		.func = _func,				\
+		.local_port = MLXSW_PORT_DONT_CARE,	\
+		.trap_id = MLXSW_TRAP_ID_##_trap_id,	\
+	}
+
 static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_FDB_MC,
-	},
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, FDB_MC),
 	/* Traps for specific L2 packet types, not trapped as FDB MC */
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_STP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_LACP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_EAPOL,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_LLDP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_MMRP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_MVRP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_RPVST,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_DHCP,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_QUERY,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V1_REPORT,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V2_REPORT,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V2_LEAVE,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IGMP_V3_REPORT,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_ARPBC,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_ARPUC,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_MTUERROR,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_TTLERROR,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_LBERROR,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_OSPF,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_IP2ME,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_RTR_INGRESS0,
-	},
-	{
-		.func = mlxsw_sp_rx_listener_func,
-		.local_port = MLXSW_PORT_DONT_CARE,
-		.trap_id = MLXSW_TRAP_ID_HOST_MISS_IPV4,
-	},
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, EAPOL),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LLDP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MMRP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MVRP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RPVST),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, DHCP),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_QUERY),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_REPORT),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_LEAVE),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V3_REPORT),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPBC),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPUC),
+	/* L3 traps */
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MTUERROR),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, TTLERROR),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LBERROR),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, OSPF),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IP2ME),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RTR_INGRESS0),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, HOST_MISS_IPV4),
 };
 
 static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
-- 
2.5.5
