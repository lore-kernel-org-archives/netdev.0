From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum: compile-in dpipe support only if devlink is enabled
Date: Sat, 26 Aug 2017 08:35:38 +0200
Message-ID: <20170826063539.2741-2-jiri@resnulli.us>
References: <20170826063539.2741-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36180 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751302AbdHZGfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2017 02:35:44 -0400
Received: by mail-wr0-f193.google.com with SMTP id p8so965905wrf.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 23:35:43 -0700 (PDT)
In-Reply-To: <20170826063539.2741-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Makes no sense to have dpipe compiled in when devlink is not enabled,
because the devlink dpipe registation is noop function. So don't compile
it in. This also fixes missing extern structs errors.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: a86f030915f2 ("mlxsw: spectrum_dpipe: Add support for IPv4 host table dump")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile         |  3 ++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h | 15 +++++++++++++++
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index 62fc42f..f9956f3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -16,8 +16,9 @@ mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
 				   spectrum_switchdev.o spectrum_router.o \
 				   spectrum_kvdl.o spectrum_acl_tcam.o \
 				   spectrum_acl.o spectrum_flower.o \
-				   spectrum_cnt.o spectrum_dpipe.o \
+				   spectrum_cnt.o \
 				   spectrum_fid.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
+mlxsw_spectrum-$(CONFIG_NET_DEVLINK) += spectrum_dpipe.o
 obj-$(CONFIG_MLXSW_MINIMAL)	+= mlxsw_minimal.o
 mlxsw_minimal-objs		:= minimal.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
index 7785f9e..c56a3d9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.h
@@ -35,9 +35,24 @@
 #ifndef _MLXSW_PIPELINE_H_
 #define _MLXSW_PIPELINE_H_
 
+#if IS_ENABLED(CONFIG_NET_DEVLINK)
+
 int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp);
 void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp);
 
+#else
+
+static inline int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return 0;
+}
+
+static inline void mlxsw_sp_dpipe_fini(struct mlxsw_sp *mlxsw_sp)
+{
+}
+
+#endif
+
 #define MLXSW_SP_DPIPE_TABLE_NAME_ERIF "mlxsw_erif"
 #define MLXSW_SP_DPIPE_TABLE_NAME_HOST4 "mlxsw_host4"
 
-- 
2.9.3
