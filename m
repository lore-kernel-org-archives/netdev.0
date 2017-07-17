From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] mlxsw: spectrum: Mark packets trapped in router
Date: Mon, 17 Jul 2017 14:15:29 +0200
Message-ID: <20170717121532.4036-2-jiri@resnulli.us>
References: <20170717121532.4036-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35124 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751315AbdGQMPh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:15:37 -0400
Received: by mail-wr0-f196.google.com with SMTP id v60so5414920wrc.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:15:36 -0700 (PDT)
In-Reply-To: <20170717121532.4036-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In commit 1c6c6d221e2b ("mlxsw: spectrum: Mirror certain packets to
CPU") we marked packets that were mirrored to the CPU, so that they
won't be flooded again by the bridge driver.

However, certain packets are trapped in the device's router block, after
passing through the bridge block where they were potentially flooded.

Mark all packets coming from L3 traps, so that they won't be potentially
flooded again by the bridge driver.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 60bf8f2..83e77b9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3334,14 +3334,14 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, ARP, false),
 	MLXSW_SP_RXL_NO_MARK(FID_MISS, TRAP_TO_CPU, IP2ME, false),
 	/* L3 traps */
-	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
-	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
-	MLXSW_SP_RXL_NO_MARK(LBERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(LBERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU, OSPF, false),
-	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU, IP2ME, false),
-	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
-	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
-	MLXSW_SP_RXL_NO_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
+	MLXSW_SP_RXL_MARK(IP2ME, TRAP_TO_CPU, IP2ME, false),
+	MLXSW_SP_RXL_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
+	MLXSW_SP_RXL_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
+	MLXSW_SP_RXL_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
 	/* PKT Sample trap */
 	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
 		  false, SP_IP2ME, DISCARD),
-- 
2.9.3
