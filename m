From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH 1/3] sh_eth: Remove redundant alignment adjustment
Date: Thu, 13 Nov 2014 16:04:59 +0900
Message-ID: <1415862301-28032-2-git-send-email-ykaneko0929@gmail.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

PTR_ALIGN macro after skb_reserve is redundant, because skb_reserve
function adjusts the alignment of skb->data.

Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 60e9c2c..49e963e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1141,7 +1141,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 
 		/* RX descriptor */
 		rxdesc = &mdp->rx_ring[i];
-		rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
+		rxdesc->addr = virt_to_phys(skb->data);
 		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);
 
 		/* The size of the buffer is 16 byte boundary. */
@@ -1477,7 +1477,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 			sh_eth_set_receive_align(skb);
 
 			skb_checksum_none_assert(skb);
-			rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
+			rxdesc->addr = virt_to_phys(skb->data);
 		}
 		if (entry >= mdp->num_rx_ring - 1)
 			rxdesc->status |=
-- 
1.9.1

