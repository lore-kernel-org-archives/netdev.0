From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/8] mlxsw: core: Create the mlxsw_fw_rev struct
Date: Tue, 23 May 2017 21:56:28 +0200
Message-ID: <20170523195630.6460-7-jiri@resnulli.us>
References: <20170523195630.6460-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com, Yuval.Mintz@cavium.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36273 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968147AbdEWT4w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 15:56:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id k15so40770824wmh.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 12:56:46 -0700 (PDT)
In-Reply-To: <20170523195630.6460-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

This struct was previously an anonymous struct defined inside the
mlxsw_bus_info struct. Extract it to a struct named mlxsw_fw_rev, as it
will be needed later by the spectrum driver.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 7fb3539..6e966af 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -344,15 +344,17 @@ struct mlxsw_bus {
 	u8 features;
 };
 
+struct mlxsw_fw_rev {
+	u16 major;
+	u16 minor;
+	u16 subminor;
+};
+
 struct mlxsw_bus_info {
 	const char *device_kind;
 	const char *device_name;
 	struct device *dev;
-	struct {
-		u16 major;
-		u16 minor;
-		u16 subminor;
-	} fw_rev;
+	struct mlxsw_fw_rev fw_rev;
 	u8 vsd[MLXSW_CMD_BOARDINFO_VSD_LEN];
 	u8 psid[MLXSW_CMD_BOARDINFO_PSID_LEN];
 };
-- 
2.9.3
