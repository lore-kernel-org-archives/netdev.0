From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix r8152_csum_workaround function
Date: Fri, 11 Jul 2014 16:48:27 +0800
Message-ID: <1394712342-15778-14-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The transport offset of the IPv4 packet should be fixed and wouldn't
be out of the hw limitation, so the r8152_csum_workaround() should
be used for IPv6 packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a795ecf..7bad2d3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1359,7 +1359,7 @@ static void r8152_csum_workaround(struct r8152 *tp, struct sk_buff *skb,
 		struct sk_buff_head seg_list;
 		struct sk_buff *segs, *nskb;
 
-		features &= ~(NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO);
+		features &= ~(NETIF_F_SG | NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 		segs = skb_gso_segment(skb, features);
 		if (IS_ERR(segs) || !segs)
 			goto drop;
-- 
1.9.3
