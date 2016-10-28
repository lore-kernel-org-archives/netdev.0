From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/16] mlxsw: switchx2: Add Infiniband switch partition
Date: Fri, 28 Oct 2016 21:35:56 +0200
Message-ID: <1477683361-8011-11-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
 <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32834 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755886AbcJ1Tqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:46:46 -0400
Received: by mail-wm0-f67.google.com with SMTP id m83so8775845wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:46:45 -0700 (PDT)
In-Reply-To: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

In order to put a port in Infiniband fabric it should be assigned
to separate swid (Switch partition) that initialized as IB swid.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/port.h     | 1 +
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/port.h b/drivers/net/ethernet/mellanox/mlxsw/port.h
index af371a8..7296071 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/port.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/port.h
@@ -44,6 +44,7 @@
 
 #define MLXSW_PORT_SWID_DISABLED_PORT	255
 #define MLXSW_PORT_SWID_ALL_SWIDS	254
+#define MLXSW_PORT_SWID_TYPE_IB		1
 #define MLXSW_PORT_SWID_TYPE_ETH	2
 
 #define MLXSW_PORT_MID			0xd000
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 8eac26f..a905589 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1590,13 +1590,17 @@ static struct mlxsw_config_profile mlxsw_sx_config_profile = {
 	.used_flood_mode		= 1,
 	.flood_mode			= 3,
 	.used_max_ib_mc			= 1,
-	.max_ib_mc			= 0,
+	.max_ib_mc			= 6,
 	.used_max_pkey			= 1,
 	.max_pkey			= 0,
 	.swid_config			= {
 		{
 			.used_type	= 1,
 			.type		= MLXSW_PORT_SWID_TYPE_ETH,
+		},
+		{
+			.used_type	= 1,
+			.type		= MLXSW_PORT_SWID_TYPE_IB,
 		}
 	},
 	.resource_query_enable		= 0,
-- 
2.5.5
