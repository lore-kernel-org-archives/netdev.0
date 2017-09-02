From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/21] mlxsw: spectrum_router: Add mlxsw_sp_ipip_ops
Date: Sat,  2 Sep 2017 23:49:17 +0200
Message-ID: <20170902214929.2890-10-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35041 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752776AbdIBVtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:47 -0400
Received: by mail-wr0-f194.google.com with SMTP id a47so1622679wra.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:46 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Details of individual tunnel types are kept in an array of
mlxsw_sp_ipip_ops objects. Follow-up patches will use the list to
determine whether a constructed RIF should be a loopback, and to decide
whether a next hop references a tunnel.

The list is currently empty, follow-up patches will add support for GRE.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/Makefile       |  4 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_ipip.c    | 38 ++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_ipip.h    | 51 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 19 ++++++++
 4 files changed, 110 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Makefile b/drivers/net/ethernet/mellanox/mlxsw/Makefile
index f9956f3..891ff41 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Makefile
+++ b/drivers/net/ethernet/mellanox/mlxsw/Makefile
@@ -16,8 +16,8 @@ mlxsw_spectrum-objs		:= spectrum.o spectrum_buffers.o \
 				   spectrum_switchdev.o spectrum_router.o \
 				   spectrum_kvdl.o spectrum_acl_tcam.o \
 				   spectrum_acl.o spectrum_flower.o \
-				   spectrum_cnt.o \
-				   spectrum_fid.o
+				   spectrum_cnt.o spectrum_fid.o \
+				   spectrum_ipip.o
 mlxsw_spectrum-$(CONFIG_MLXSW_SPECTRUM_DCB)	+= spectrum_dcb.o
 mlxsw_spectrum-$(CONFIG_NET_DEVLINK) += spectrum_dpipe.o
 obj-$(CONFIG_MLXSW_MINIMAL)	+= mlxsw_minimal.o
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
new file mode 100644
index 0000000..20b0b96
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
@@ -0,0 +1,38 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.c
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Petr Machata <petrm@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "spectrum_ipip.h"
+
+const struct mlxsw_sp_ipip_ops *mlxsw_sp_ipip_ops_arr[] = {
+};
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h
new file mode 100644
index 0000000..65eb493
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h
@@ -0,0 +1,51 @@
+/*
+ * drivers/net/ethernet/mellanox/mlxsw/spectrum_ipip.h
+ * Copyright (c) 2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2017 Petr Machata <petrm@mellanox.com>
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the names of the copyright holders nor the names of its
+ *    contributors may be used to endorse or promote products derived from
+ *    this software without specific prior written permission.
+ *
+ * Alternatively, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") version 2 as published by the Free
+ * Software Foundation.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef _MLXSW_IPIP_H_
+#define _MLXSW_IPIP_H_
+
+#include "spectrum_router.h"
+
+enum mlxsw_sp_ipip_type {
+	MLXSW_SP_IPIP_TYPE_MAX,
+};
+
+struct mlxsw_sp_ipip_ops {
+	int dev_type;
+	enum mlxsw_sp_l3proto ul_proto; /* Underlay. */
+};
+
+extern const struct mlxsw_sp_ipip_ops *mlxsw_sp_ipip_ops_arr[];
+
+#endif /* _MLXSW_IPIP_H_*/
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index f866ac5..f85d249 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -62,6 +62,7 @@
 #include "reg.h"
 #include "spectrum_cnt.h"
 #include "spectrum_dpipe.h"
+#include "spectrum_ipip.h"
 #include "spectrum_router.h"
 
 struct mlxsw_sp_vr;
@@ -89,6 +90,7 @@ struct mlxsw_sp_router {
 	bool aborted;
 	struct notifier_block fib_nb;
 	const struct mlxsw_sp_rif_ops **rif_ops_arr;
+	const struct mlxsw_sp_ipip_ops **ipip_ops_arr;
 };
 
 struct mlxsw_sp_rif {
@@ -5152,6 +5154,16 @@ static void mlxsw_sp_rifs_fini(struct mlxsw_sp *mlxsw_sp)
 	kfree(mlxsw_sp->router->rifs);
 }
 
+static int mlxsw_sp_ipips_init(struct mlxsw_sp *mlxsw_sp)
+{
+	mlxsw_sp->router->ipip_ops_arr = mlxsw_sp_ipip_ops_arr;
+	return 0;
+}
+
+static void mlxsw_sp_ipips_fini(struct mlxsw_sp *mlxsw_sp)
+{
+}
+
 static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
 {
 	struct mlxsw_sp_router *router;
@@ -5211,6 +5223,10 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 	if (err)
 		goto err_rifs_init;
 
+	err = mlxsw_sp_ipips_init(mlxsw_sp);
+	if (err)
+		goto err_ipips_init;
+
 	err = rhashtable_init(&mlxsw_sp->router->nexthop_ht,
 			      &mlxsw_sp_nexthop_ht_params);
 	if (err)
@@ -5252,6 +5268,8 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 err_nexthop_group_ht_init:
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
 err_nexthop_ht_init:
+	mlxsw_sp_ipips_fini(mlxsw_sp);
+err_ipips_init:
 	mlxsw_sp_rifs_fini(mlxsw_sp);
 err_rifs_init:
 	__mlxsw_sp_router_fini(mlxsw_sp);
@@ -5268,6 +5286,7 @@ void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 	mlxsw_sp_lpm_fini(mlxsw_sp);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_group_ht);
 	rhashtable_destroy(&mlxsw_sp->router->nexthop_ht);
+	mlxsw_sp_ipips_fini(mlxsw_sp);
 	mlxsw_sp_rifs_fini(mlxsw_sp);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 	kfree(mlxsw_sp->router);
-- 
2.9.3
