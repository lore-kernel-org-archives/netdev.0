From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: spectrum: Add another partition to KVD linear
Date: Sun, 22 Oct 2017 23:11:50 +0200
Message-ID: <20171022211150.2567-9-jiri@resnulli.us>
References: <20171022211150.2567-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:46511 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932175AbdJVVL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 17:11:59 -0400
Received: by mail-wr0-f196.google.com with SMTP id l1so15506210wrc.3
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 14:11:58 -0700 (PDT)
In-Reply-To: <20171022211150.2567-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The KVD linear is currently partitioned into two partitions. One for
single entries and another for groups of 32 entries.

Add another partition consisting of groups of 512 entries which will
allow us to more accurately represent the nexthop weights in non-equal
cost multi-path routing.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
index 266b3af..310c382 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_kvdl.c
@@ -41,13 +41,22 @@
 #define MLXSW_SP_KVDL_SINGLE_SIZE 16384
 #define MLXSW_SP_KVDL_SINGLE_END \
 	(MLXSW_SP_KVDL_SINGLE_SIZE + MLXSW_SP_KVDL_SINGLE_BASE - 1)
+
 #define MLXSW_SP_KVDL_CHUNKS_BASE \
 	(MLXSW_SP_KVDL_SINGLE_BASE + MLXSW_SP_KVDL_SINGLE_SIZE)
-#define MLXSW_SP_KVDL_CHUNKS_SIZE \
-	(MLXSW_SP_KVD_LINEAR_SIZE - MLXSW_SP_KVDL_CHUNKS_BASE)
+#define MLXSW_SP_KVDL_CHUNKS_SIZE 49152
 #define MLXSW_SP_KVDL_CHUNKS_END \
 	(MLXSW_SP_KVDL_CHUNKS_SIZE + MLXSW_SP_KVDL_CHUNKS_BASE - 1)
+
+#define MLXSW_SP_KVDL_LARGE_CHUNKS_BASE \
+	(MLXSW_SP_KVDL_CHUNKS_BASE + MLXSW_SP_KVDL_CHUNKS_SIZE)
+#define MLXSW_SP_KVDL_LARGE_CHUNKS_SIZE \
+	(MLXSW_SP_KVD_LINEAR_SIZE - MLXSW_SP_KVDL_LARGE_CHUNKS_BASE)
+#define MLXSW_SP_KVDL_LARGE_CHUNKS_END \
+	(MLXSW_SP_KVDL_LARGE_CHUNKS_SIZE + MLXSW_SP_KVDL_LARGE_CHUNKS_BASE - 1)
+
 #define MLXSW_SP_CHUNK_MAX 32
+#define MLXSW_SP_LARGE_CHUNK_MAX 512
 
 struct mlxsw_sp_kvdl_part_info {
 	unsigned int part_index;
@@ -192,6 +201,12 @@ static const struct mlxsw_sp_kvdl_part_info kvdl_parts_info[] = {
 		.end_index	= MLXSW_SP_KVDL_CHUNKS_END,
 		.alloc_size	= MLXSW_SP_CHUNK_MAX,
 	},
+	{
+		.part_index	= 2,
+		.start_index	= MLXSW_SP_KVDL_LARGE_CHUNKS_BASE,
+		.end_index	= MLXSW_SP_KVDL_LARGE_CHUNKS_END,
+		.alloc_size	= MLXSW_SP_LARGE_CHUNK_MAX,
+	},
 };
 
 static struct mlxsw_sp_kvdl_part *
-- 
2.9.5
