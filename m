From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4_en: remove redundant code
Date: Thu, 17 Jan 2013 07:26:07 -0800
Message-ID: <1358436367.29723.49.camel@edumazet-glaptop>
References: <1358423241-2452-1-git-send-email-amirv@mellanox.com>
	 <1358423241-2452-6-git-send-email-amirv@mellanox.com>
	 <1358432538.29723.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60753 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756558Ab3AQP0K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:26:10 -0500
Received: by mail-pa0-f54.google.com with SMTP id bi5so1535150pad.27
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 07:26:10 -0800 (PST)
In-Reply-To: <1358432538.29723.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

remove redundant code from build_inline_wqe()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Amir, reviewing this driver, it looks like following could be done,
could you test the patch for me ?

Thanks

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2b799f4..16af338 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -515,10 +515,6 @@ static void build_inline_wqe(struct mlx4_en_tx_desc *tx_desc, struct sk_buff *sk
 		wmb();
 		inl->byte_count = cpu_to_be32(1 << 31 | (skb->len - spc));
 	}
-	tx_desc->ctrl.vlan_tag = cpu_to_be16(*vlan_tag);
-	tx_desc->ctrl.ins_vlan = MLX4_WQE_CTRL_INS_VLAN *
-		(!!vlan_tx_tag_present(skb));
-	tx_desc->ctrl.fence_size = (real_size / 16) & 0x3f;
 }
 
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb)
