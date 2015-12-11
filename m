From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: core: Fix temperature sensor index during initialization
Date: Fri, 11 Dec 2015 18:26:00 +0100
Message-ID: <1449854760-15190-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35130 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbbLKR0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 12:26:05 -0500
Received: by mail-wm0-f45.google.com with SMTP id l68so23811736wml.0
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 09:26:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Sensor index should be passed instead of 0. For now, this does not make
a difference, since there is so far only one temperature sensor
exposed by HW.

Fixes: 89309da39 ("mlxsw: core: Implement temperature hwmon interface")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index 4dad146..5fada34 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -242,7 +242,7 @@ static int mlxsw_hwmon_temp_init(struct mlxsw_hwmon *mlxsw_hwmon)
 	}
 	sensor_count = mlxsw_reg_mtcap_sensor_count_get(mtcap_pl);
 	for (i = 0; i < sensor_count; i++) {
-		mlxsw_reg_mtmp_pack(mtmp_pl, 0, true, true);
+		mlxsw_reg_mtmp_pack(mtmp_pl, i, true, true);
 		err = mlxsw_reg_write(mlxsw_hwmon->core,
 				      MLXSW_REG(mtmp), mtmp_pl);
 		if (err) {
-- 
1.9.3
