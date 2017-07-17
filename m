From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] mlxsw: spectrum: Trap IPv4 packets with Router Alert option
Date: Mon, 17 Jul 2017 14:15:30 +0200
Message-ID: <20170717121532.4036-3-jiri@resnulli.us>
References: <20170717121532.4036-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33301 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdGQMPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:15:38 -0400
Received: by mail-wr0-f195.google.com with SMTP id 40so2509429wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:15:38 -0700 (PDT)
In-Reply-To: <20170717121532.4036-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case local sockets have the IP_ROUTER_ALERT socket option set, then
they expect to get packets with the Router Alert option.

Trap such packets, so that the kernel could inspect them and potentially
send them to interested sockets.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 83e77b9..bc35b40 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3342,6 +3342,7 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
 	MLXSW_SP_RXL_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
 	MLXSW_SP_RXL_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
+	MLXSW_SP_RXL_MARK(ROUTER_ALERT_IPV4, TRAP_TO_CPU, ROUTER_EXP, false),
 	/* PKT Sample trap */
 	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
 		  false, SP_IP2ME, DISCARD),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 12b5ed58..4946d4e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -66,6 +66,7 @@ enum {
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
 	MLXSW_TRAP_ID_BGP_IPV4 = 0x88,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
+	MLXSW_TRAP_ID_ROUTER_ALERT_IPV4 = 0xD6,
 	MLXSW_TRAP_ID_ACL0 = 0x1C0,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
-- 
2.9.3
