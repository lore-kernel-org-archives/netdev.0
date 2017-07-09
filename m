From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 2/7] net/mlx5: IPSec, Fix 64-bit division on 32-bit builds
Date: Sun,  9 Jul 2017 15:49:12 +0300
Message-ID: <20170709124917.12852-3-saeedm@mellanox.com>
References: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36249 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752191AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
In-Reply-To: <20170709124917.12852-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Fix warnings when building 386 kernel:
>> ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.ko] undefined!

Fixes: 2ac9cfe78223 ("net/mlx5e: IPSec, Add Innova IPSec offload TX data path")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
index 4a78aefdf157..7d06c673851a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
@@ -363,6 +363,7 @@ void mlx5e_ipsec_build_inverse_table(void)
 {
 	u16 mss_inv;
 	u32 mss;
+	u64 n;
 
 	/* Calculate 1/x inverse table for use in GSO data path.
 	 * Using this table, we provide the IPSec accelerator with the value of
@@ -372,7 +373,8 @@ void mlx5e_ipsec_build_inverse_table(void)
 	 */
 	mlx5e_ipsec_inverse_table[1] = htons(0xFFFF);
 	for (mss = 2; mss < MAX_LSO_MSS; mss++) {
-		mss_inv = ((1ULL << 32) / mss) >> 16;
+		n = 1ULL << 32;
+		mss_inv = do_div(n, mss) >> 16;
 		mlx5e_ipsec_inverse_table[mss] = htons(mss_inv);
 	}
 }
-- 
2.11.0
