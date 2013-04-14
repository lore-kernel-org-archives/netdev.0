From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next] vxlan: use htonl when snooping for loopback address
Date: Sun, 14 Apr 2013 12:21:39 +0300
Message-ID: <1365931299-26240-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:47370 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750967Ab3DNJ2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 05:28:51 -0400
Received: by mail-we0-f200.google.com with SMTP id m1so1622120wea.3
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 02:28:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently "bridge fdb show dev vxlan0" lists loopback address as
"1.0.0.127". Using htonl(INADDR_LOOPBACK) rather than passing it
directly to vxlan_snoop fixes the problem.

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 drivers/net/vxlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ee02ecd..725aba3 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -925,7 +925,8 @@ static void vxlan_encap_bypass(struct sk_buff *skb, struct vxlan_dev *src_vxlan,
 	__skb_pull(skb, skb_network_offset(skb));
 
 	if (dst_vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, INADDR_LOOPBACK, eth_hdr(skb)->h_source);
+		vxlan_snoop(skb->dev, htonl(INADDR_LOOPBACK),
+			    eth_hdr(skb)->h_source);
 
 	u64_stats_update_begin(&tx_stats->syncp);
 	tx_stats->tx_packets++;
-- 
1.8.1.5
