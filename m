From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net/hsr: Check skb_put_padto() return value
Date: Mon, 21 Aug 2017 12:59:10 -0700
Message-ID: <20170821195910.28752-1-f.fainelli@gmail.com>
Cc: mail@pheise.de, peter.heise@airbus.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Arvid Brodin <arvid.brodin@alten.se>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_put_padto() will free the sk_buff passed as reference in case of
errors, but we still need to check its return value and decide what to
do.

Detected by CoverityScan, CID#1416688 ("CHECKED_RETURN")

Fixes: ee1c27977284 ("net/hsr: Added support for HSR v1")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/hsr/hsr_device.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 4e7bdb213cd0..172d8309f89e 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -314,7 +314,8 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	hsr_sp = skb_put(skb, sizeof(struct hsr_sup_payload));
 	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
 
-	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
+	if (skb_put_padto(skb, ETH_ZLEN + HSR_HLEN))
+		return;
 
 	hsr_forward_skb(skb, master);
 	return;
-- 
2.9.3
