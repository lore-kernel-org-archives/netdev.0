From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum: Increase number of linear entries
Date: Sun, 22 Oct 2017 23:11:49 +0200
Message-ID: <20171022211150.2567-8-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:53528 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932133AbdJVVL6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:58 -0400
Received: by mail-wr0-f193.google.com with SMTP id u40so9613909wrf.10
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:58 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The memory region where adjacency entries (nexthops) are stored is
called the KVD linear and is configured during initialization with a
size of 64K.

Extend this area with 32K more entries, that will be partitioned into 64
groups of 0.5K entries, thereby allowing us to support weighted nexthops
with high accuracy.

Change the ratio between both types of hash entries, so as to prevent
reduction in the number of double hash entries, which are used for IPv6
neighbours and routes with a prefix length greater than 64.

Note that the user will be able to control all these sizes once the
devlink resource manager is introduced.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1bc3fc3..12b6ac4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3885,8 +3885,8 @@ static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.max_pkey			= 0,
 	.used_kvd_split_data		= 1,
 	.kvd_hash_granularity		= MLXSW_SP_KVD_GRANULARITY,
-	.kvd_hash_single_parts		= 2,
-	.kvd_hash_double_parts		= 1,
+	.kvd_hash_single_parts		= 59,
+	.kvd_hash_double_parts		= 41,
 	.kvd_linear_size		= MLXSW_SP_KVD_LINEAR_SIZE,
 	.swid_config			= {
 		{
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 78ff20d..dc1b739 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -62,7 +62,7 @@
 
 #define MLXSW_SP_PORT_BASE_SPEED 25000	/* Mb/s */
 
-#define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
+#define MLXSW_SP_KVD_LINEAR_SIZE 98304 /* entries */
 #define MLXSW_SP_KVD_GRANULARITY 128
 
 struct mlxsw_sp_port;
-- 
2.9.5
