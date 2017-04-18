From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: spectrum: Add FID miss trap
Date: Tue, 18 Apr 2017 16:55:38 +0200
Message-ID: <1492527338-13298-9-git-send-email-jiri@resnulli.us>
References: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35538 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754189AbdDROz5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:57 -0400
Received: by mail-wm0-f66.google.com with SMTP id d79so15277017wmi.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:56 -0700 (PDT)
In-Reply-To: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When there is no FID set for a specific packet, the HW will drop it.
However, by default these packets are useful to be delivered to CPU as
it can inspect them and program HW accordingly. So add this trap.

This would only ever happen when port is enslaved to an OVS master.
Otherwise, packets would be dropped during VLAN / STP filtering,
before FID classification.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 +
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f1c1b01..20c1b6c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3008,6 +3008,7 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(IGMP_V3_REPORT, TRAP_TO_CPU, IGMP, false),
 	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU, ARP, false),
 	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, ARP, false),
+	MLXSW_SP_RXL_NO_MARK(FID_MISS, TRAP_TO_CPU, IP2ME, false),
 	/* L3 traps */
 	MLXSW_SP_RXL_NO_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_NO_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 02ea48b..e008fdb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -55,6 +55,7 @@ enum {
 	MLXSW_TRAP_ID_IGMP_V2_LEAVE = 0x33,
 	MLXSW_TRAP_ID_IGMP_V3_REPORT = 0x34,
 	MLXSW_TRAP_ID_PKT_SAMPLE = 0x38,
+	MLXSW_TRAP_ID_FID_MISS = 0x3D,
 	MLXSW_TRAP_ID_ARPBC = 0x50,
 	MLXSW_TRAP_ID_ARPUC = 0x51,
 	MLXSW_TRAP_ID_MTUERROR = 0x52,
-- 
2.7.4
