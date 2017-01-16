From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 2/9] net/mlx4_core: Device revision support
Date: Mon, 16 Jan 2017 19:29:58 +0200
Message-ID: <1484587805-12666-3-git-send-email-tariqt@mellanox.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yishai Hadas <yishaih@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43784 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751031AbdAPRar (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:30:47 -0500
In-Reply-To: <1484587805-12666-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yishai Hadas <yishaih@mellanox.com>

The device revision field returned by the NodeInfo MAD is incorrect
on ConnectX3 devices.

This patch is driver side handling to complete a FW fix added at 2.11.1172.
INIT_HCA - bit at offset 0x0C.12 is set to 1 so that FW will report
correct device revision.

Older FW versions won't be affected from turning on that bit,
no capability bit is needed.

Signed-off-by: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 25b5b32e958f..de39a5db4a6f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1875,7 +1875,7 @@ int mlx4_INIT_HCA(struct mlx4_dev *dev, struct mlx4_init_hca_param *param)
 	*((u8 *) mailbox->buf + INIT_HCA_VERSION_OFFSET) = INIT_HCA_VERSION;
 
 	*((u8 *) mailbox->buf + INIT_HCA_CACHELINE_SZ_OFFSET) =
-		(ilog2(cache_line_size()) - 4) << 5;
+		((ilog2(cache_line_size()) - 4) << 5) | (1 << 4);
 
 #if defined(__LITTLE_ENDIAN)
 	*(inbox + INIT_HCA_FLAGS_OFFSET / 4) &= ~cpu_to_be32(1 << 1);
-- 
1.8.3.1
