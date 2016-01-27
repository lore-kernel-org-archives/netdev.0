From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 05/11] mlxsw: spectrum: Disable learning according to STP state
Date: Wed, 27 Jan 2016 15:20:20 +0100
Message-ID: <1453904426-4960-6-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33354 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbcA0OUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:37 -0500
Received: by mail-wm0-f50.google.com with SMTP id l66so4883218wml.0
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:36 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When port is put into LISTENING state it shouldn't populate the FDB, so
set the port's STP state in hardware to DISCARDING instead of LEARNING.
It will therefore keep listening to BPDU packets, but discard other
non-control packets and won't perform any learning.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 913488e..94ac5ee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -128,10 +128,10 @@ static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	case BR_STATE_FORWARDING:
 		spms_state = MLXSW_REG_SPMS_STATE_FORWARDING;
 		break;
-	case BR_STATE_LISTENING: /* fall-through */
 	case BR_STATE_LEARNING:
 		spms_state = MLXSW_REG_SPMS_STATE_LEARNING;
 		break;
+	case BR_STATE_LISTENING: /* fall-through */
 	case BR_STATE_DISABLED: /* fall-through */
 	case BR_STATE_BLOCKING:
 		spms_state = MLXSW_REG_SPMS_STATE_DISCARDING;
-- 
1.9.3
