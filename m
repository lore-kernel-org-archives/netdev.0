From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/19] mlxsw: spectrum: Add BGP trap
Date: Fri, 25 Nov 2016 10:33:43 +0100
Message-ID: <1480066427-3961-16-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33726 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id u144so7192562wmu.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:07 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add a trap for BGP protocol that was previously trapped by the generic trap
for IP2ME. This trap will allow us to have better control (over priority
and rate) of the traffic.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 75ba22a..42ac968 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2761,6 +2761,7 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(IP2ME, TRAP_TO_CPU, false),
 	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, false),
 	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, false),
+	MLXSW_SP_RXL_MARK(BGP_IPV4, TRAP_TO_CPU, false),
 };
 
 static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index ed8e301..7ab275d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -62,6 +62,7 @@ enum {
 	MLXSW_TRAP_ID_OSPF = 0x55,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
+	MLXSW_TRAP_ID_BGP_IPV4 = 0x88,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
-- 
2.7.4
