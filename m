From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4_en: remove sparse errors
Date: Mon, 05 Mar 2012 07:01:14 -0800
Message-ID: <1330959674.2474.24.camel@edumazet-laptop>
References: <1330167065.2462.53.camel@edumazet-laptop>
	 <CAJZOPZKAwrx-u_onDQCCxipkLPdZkPE6cokRtZOa1uRZiZTYug@mail.gmail.com>
	 <1330876610.2730.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:36505 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932150Ab2CEPBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 10:01:16 -0500
Received: by pbcun15 with SMTP id un15so2864496pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 07:01:16 -0800 (PST)
In-Reply-To: <1330876610.2730.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix new sparse errors introduced in commit 6221217199 (mlx4_en: dont
change mac_header on xmit)

Reported-by: Or Gerlitz <or.gerlitz@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2fd5140..50b3fa5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -686,8 +686,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Copy dst mac address to wqe */
 	ethh = (struct ethhdr *)skb->data;
-	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((u16 *)ethh->h_dest);
-	tx_desc->ctrl.imm = get_unaligned((u32 *)(ethh->h_dest + 2));
+	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
+	tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
