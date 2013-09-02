From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: NAPI requires netif_receive_skb()
Date: Tue, 3 Sep 2013 03:03:10 +0400
Message-ID: <201309030303.11381.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver supporting NAPI should use NAPI-specific function for receiving packets,
so netif_rx() should be changed to netif_receive_skb().

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against Dave's 'net-next.git' repo (it also applies to 'net.git'
with offset). Perhaps it should  be backported to 3.11 once it is out...

 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1347,7 +1347,7 @@ static int sh_eth_rx(struct net_device *
 				skb_reserve(skb, NET_IP_ALIGN);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, ndev);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			ndev->stats.rx_packets++;
 			ndev->stats.rx_bytes += pkt_len;
 		}
