From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx4_en: Set csum level for encapsulated packets
Date: Thu,  4 Dec 2014 15:13:46 +0200
Message-ID: <1417698835-11050-2-git-send-email-ogerlitz@mellanox.com>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48840 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751606AbaLDNOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 08:14:00 -0500
In-Reply-To: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was dropped by mistake for the napi_gro_frags flow, fix that.

Fixes: dd65beac48a5 ('net/mlx4_en: Extend usage of napi_gro_frags')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 946d352..3a9f9bf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -886,6 +886,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			gro_skb->len = length;
 			gro_skb->data_len = length;
 			gro_skb->ip_summed = ip_summed;
+			if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
+				gro_skb->csum_level = 1;
 
 			if (l2_tunnel && ip_summed == CHECKSUM_UNNECESSARY)
 				gro_skb->encapsulation = 1;
-- 
1.7.1
