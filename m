From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: support __GFP_MEMALLOC for rx
Date: Tue, 17 Jan 2017 20:14:10 -0800
Message-ID: <1484712850.13165.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35588 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdAREoU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 23:44:20 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so230958pfa.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 20:44:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 04aeb56a1732 ("net/mlx4_en: allocate non 0-order pages for RX
ring with __GFP_NOMEMALLOC") added code that appears to be not needed at
that time, since mlx4 never used __GFP_MEMALLOC allocations anyway.

As using memory reserves is a must in some situations (swap over NFS or
iSCSI), this patch adds this flag.

Note that this driver does not reuse pages (yet) so we do not have to
add anything else.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index eac527e25ec902c2a586e9952272b9e8e599e2c8..e362f99334d03c0df4d88320977670015870dd9c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -706,7 +706,8 @@ static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
 	do {
 		if (mlx4_en_prepare_rx_desc(priv, ring,
 					    ring->prod & ring->size_mask,
-					    GFP_ATOMIC | __GFP_COLD))
+					    GFP_ATOMIC | __GFP_COLD |
+					    __GFP_MEMALLOC))
 			break;
 		ring->prod++;
 	} while (--missing);
