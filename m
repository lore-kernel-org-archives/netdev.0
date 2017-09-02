From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 19/21] mlxsw: spectrum: Register for IPIP_DECAP_ERROR trap
Date: Sat,  2 Sep 2017 23:49:27 +0200
Message-ID: <20170902214929.2890-20-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37578 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752863AbdIBVuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:50:02 -0400
Received: by mail-wr0-f193.google.com with SMTP id y15so1123231wrc.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:50:02 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

These traps are generated for packets that fail checks for source IP,
encapsulation type, or GRE key. Trap these packets to CPU for follow-up
handling by the kernel, which will send ICMP destination unreachable
responses.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 992cbfa..ed7cd6c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3400,6 +3400,7 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(HOST_MISS_IPV6, TRAP_TO_CPU, HOST_MISS, false),
 	MLXSW_SP_RXL_MARK(ROUTER_ALERT_IPV4, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_MARK(ROUTER_ALERT_IPV6, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(IPIP_DECAP_ERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	/* PKT Sample trap */
 	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
 		  false, SP_IP2ME, DISCARD),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 6165239..f396a1f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -85,6 +85,7 @@ enum {
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
 	MLXSW_TRAP_ID_IPV6_MC_LINK_LOCAL_DEST = 0x91,
 	MLXSW_TRAP_ID_HOST_MISS_IPV6 = 0x92,
+	MLXSW_TRAP_ID_IPIP_DECAP_ERROR = 0xB1,
 	MLXSW_TRAP_ID_ROUTER_ALERT_IPV4 = 0xD6,
 	MLXSW_TRAP_ID_ROUTER_ALERT_IPV6 = 0xD7,
 	MLXSW_TRAP_ID_ACL0 = 0x1C0,
-- 
2.9.3
