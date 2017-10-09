From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/3] net/mlx4_core: Fix cast warning in fw.c
Date: Mon,  9 Oct 2017 16:59:49 +0300
Message-ID: <1507557590-17747-3-git-send-email-tariqt@mellanox.com>
References: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33682 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755141AbdJIOAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 10:00:04 -0400
In-Reply-To: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following SPARSE warning, in MLX4_GET() macro:
drivers/net/ethernet/mellanox/mlx4/fw.c:233:9: warning: cast to restricted __be64

Fixes: 17d5ceb6e43e ("net/mlx4_core: Fix unaligned accesses")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 16c09949afd5..634f603f941c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -57,12 +57,12 @@ enum {
 #define MLX4_GET(dest, source, offset)				      \
 	do {							      \
 		void *__p = (char *) (source) + (offset);	      \
-		u64 val;                                              \
-		switch (sizeof(dest)) {			      \
+		__be64 val;                                           \
+		switch (sizeof(dest)) {				      \
 		case 1: (dest) = *(u8 *) __p;	    break;	      \
 		case 2: (dest) = be16_to_cpup(__p); break;	      \
 		case 4: (dest) = be32_to_cpup(__p); break;	      \
-		case 8: val = get_unaligned((u64 *)__p);              \
+		case 8: val = get_unaligned((__be64 *)__p);           \
 			(dest) = be64_to_cpu(val);  break;            \
 		default: __buggy_use_of_MLX4_GET();		      \
 		}						      \
-- 
1.8.3.1
