From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] mlx4: reduce OOM risk on arches with large pages
Date: Sat, 18 Feb 2017 10:34:18 -0800
Message-ID: <1487442858.1311.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35082 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753412AbdBRSe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 13:34:58 -0500
Received: by mail-pf0-f195.google.com with SMTP id 68so6569209pfx.2
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 10:34:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since mlx4 NIC are used on PowerPC with 64K pages, we need to adapt
MLX4_EN_ALLOC_PREFER_ORDER definition.

Otherwise, a fragment sitting in an out of order TCP queue can hold
0.5 Mbytes and it is a serious OOM risk.

Fixes: 51151a16a60f ("mlx4: allow order-0 memory allocations in RX path")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index cec59bc264c9ac197048fd7c98bcd5cf25de0efd..0f6d2f3b7d54f51de359d4ccde21f4585e6b7852 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -102,7 +102,8 @@
 /* Use the maximum between 16384 and a single page */
 #define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
 
-#define MLX4_EN_ALLOC_PREFER_ORDER	PAGE_ALLOC_COSTLY_ORDER
+#define MLX4_EN_ALLOC_PREFER_ORDER min_t(int, get_order(32768),		\
+					 PAGE_ALLOC_COSTLY_ORDER)
 
 /* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
  * and 4K allocations) */
