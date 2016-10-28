From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/16] mlxsw: core: Zero payload buffers for couple of registers
Date: Fri, 28 Oct 2016 21:35:46 +0200
Message-ID: <1477683361-8011-1-git-send-email-jiri@resnulli.us>
References: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32794 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756632AbcJ1TiV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 15:38:21 -0400
Received: by mail-wm0-f66.google.com with SMTP id m83so8750872wmc.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 12:38:20 -0700 (PDT)
In-Reply-To: <1477682270-7903-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

We recently discovered a bug in the firmware in which a field's length in
one of the registers was incorrectly set. This caused the firmware to
access garbage data that wasn't initialized by the driver and therefore
emit error messages.

While the bug is already fixed and the driver usually zeros the buffers
passed to the firmware, there are a handful of cases where this isn't
done. Zero the buffer in these cases and prevent similar bugs from
recurring, as they tend to be hard to debug.

Fixes: 52581961d83d ("mlxsw: core: Implement fan control using hwmon")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c   | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c   | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index 1ac8bf1..ab710e3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -262,7 +262,7 @@ static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
 
 static int mlxsw_hwmon_temp_init(struct mlxsw_hwmon *mlxsw_hwmon)
 {
-	char mtcap_pl[MLXSW_REG_MTCAP_LEN];
+	char mtcap_pl[MLXSW_REG_MTCAP_LEN] = {0};
 	char mtmp_pl[MLXSW_REG_MTMP_LEN];
 	u8 sensor_count;
 	int i;
@@ -295,7 +295,7 @@ static int mlxsw_hwmon_temp_init(struct mlxsw_hwmon *mlxsw_hwmon)
 
 static int mlxsw_hwmon_fans_init(struct mlxsw_hwmon *mlxsw_hwmon)
 {
-	char mfcr_pl[MLXSW_REG_MFCR_LEN];
+	char mfcr_pl[MLXSW_REG_MFCR_LEN] = {0};
 	enum mlxsw_reg_mfcr_pwm_frequency freq;
 	unsigned int type_index;
 	unsigned int num;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d652f7f..2573faa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -158,7 +158,7 @@ static void mlxsw_sp_txhdr_construct(struct sk_buff *skb,
 
 static int mlxsw_sp_base_mac_get(struct mlxsw_sp *mlxsw_sp)
 {
-	char spad_pl[MLXSW_REG_SPAD_LEN];
+	char spad_pl[MLXSW_REG_SPAD_LEN] = {0};
 	int err;
 
 	err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(spad), spad_pl);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 8c8f5d8..8d11e5447 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -890,7 +890,7 @@ static const struct switchdev_ops mlxsw_sx_port_switchdev_ops = {
 
 static int mlxsw_sx_hw_id_get(struct mlxsw_sx *mlxsw_sx)
 {
-	char spad_pl[MLXSW_REG_SPAD_LEN];
+	char spad_pl[MLXSW_REG_SPAD_LEN] = {0};
 	int err;
 
 	err = mlxsw_reg_query(mlxsw_sx->core, MLXSW_REG(spad), spad_pl);
-- 
2.5.5
