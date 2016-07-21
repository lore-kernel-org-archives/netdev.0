From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/9] mlxsw: pci: Add max span resources to resources query
Date: Thu, 21 Jul 2016 10:19:13 +0200
Message-ID: <1469089160-4239-3-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35897 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbcGUITZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:25 -0400
Received: by mail-wm0-f67.google.com with SMTP id x83so1634641wma.3
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:25 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add max span resources to resources query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/pci.c  | 5 +++++
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index d57ad0d..d3476ea 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -268,6 +268,8 @@ struct mlxsw_driver {
 };
 
 struct mlxsw_resources {
+	u8	max_span_valid:1;
+	u8      max_span;
 };
 
 struct mlxsw_resources *mlxsw_core_resources_get(struct mlxsw_core *mlxsw_core);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 6408cc9..0b3b342 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1155,6 +1155,7 @@ mlxsw_pci_config_profile_swid_config(struct mlxsw_pci *mlxsw_pci,
 }
 
 #define MLXSW_RESOURCES_TABLE_END_ID 0xffff
+#define MLXSW_MAX_SPAN_ID 0x2420
 #define MLXSW_RESOURCES_QUERY_MAX_QUERIES 100
 #define MLXSW_RESOURCES_PER_QUERY 32
 
@@ -1163,6 +1164,10 @@ mlxsw_pci_resources_query_parse(int id, u64 val,
 				struct mlxsw_resources *resources)
 {
 	switch (id) {
+	case MLXSW_MAX_SPAN_ID:
+		resources->max_span = val;
+		resources->max_span_valid = 1;
+		break;
 	default:
 		break;
 	}
-- 
2.5.5
