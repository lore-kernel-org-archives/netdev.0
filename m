From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH 07/10] IB/mlx4: reuse mlx4_mac_to_u64()
Date: Tue,  3 Feb 2015 16:48:35 +0200
Message-ID: <1422974919-28084-8-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60163 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965506AbbBCOuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:50:32 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

This function is implemented twice... get rid of one copy.

Signed-off-by: Moni Shoua <monis@mellanox.com>
---
 drivers/infiniband/hw/mlx4/qp.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index cf000b7..2f85fc7 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -40,6 +40,7 @@
 #include <rdma/ib_addr.h>
 #include <rdma/ib_mad.h>
 
+#include <linux/mlx4/driver.h>
 #include <linux/mlx4/qp.h>
 
 #include "mlx4_ib.h"
@@ -93,17 +94,6 @@ enum {
 #ifndef ETH_ALEN
 #define ETH_ALEN        6
 #endif
-static inline u64 mlx4_mac_to_u64(u8 *addr)
-{
-	u64 mac = 0;
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++) {
-		mac <<= 8;
-		mac |= addr[i];
-	}
-	return mac;
-}
 
 static const __be32 mlx4_ib_opcode[] = {
 	[IB_WR_SEND]				= cpu_to_be32(MLX4_OPCODE_SEND),
-- 
1.7.1
