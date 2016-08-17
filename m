From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 05/10] mlxsw: spectrum: Add missing packet traps
Date: Wed, 17 Aug 2016 16:39:32 +0200
Message-ID: <1471444777-3412-6-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36786 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbcHQOjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:47 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so24727024wmf.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:46 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Add the following traps:

1) MTU Error: Trap packets whose size is bigger than the egress RIF's
MTU. If DF bit isn't set, traffic will continue to be routed in slow
path.

2) TTL Error: Trap packets whose TTL expired. This allows traceroute to
work properly.

3) OSPF packets.

Fixes: 7b27ce7bb9cd ("mlxsw: spectrum: Add traps needed for router implementation")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 15 +++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  3 +++
 2 files changed, 18 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 12681db..6b69c8a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2651,6 +2651,21 @@ static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
 	{
 		.func = mlxsw_sp_rx_listener_func,
 		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_MTUERROR,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_TTLERROR,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_OSPF,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
 		.trap_id = MLXSW_TRAP_ID_IP2ME,
 	},
 	{
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 470d769..9508e0a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -56,6 +56,9 @@ enum {
 	MLXSW_TRAP_ID_IGMP_V3_REPORT = 0x34,
 	MLXSW_TRAP_ID_ARPBC = 0x50,
 	MLXSW_TRAP_ID_ARPUC = 0x51,
+	MLXSW_TRAP_ID_MTUERROR = 0x52,
+	MLXSW_TRAP_ID_TTLERROR = 0x53,
+	MLXSW_TRAP_ID_OSPF = 0x55,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
-- 
2.5.5
