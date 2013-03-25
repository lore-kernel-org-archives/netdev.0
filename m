From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 2/3] Revert "udp: increase inner ip header ID during segmentation"
Date: Sun, 24 Mar 2013 20:36:23 -0700
Message-ID: <1364182583-1733-1-git-send-email-pshelar@nicira.com>
Cc: amwang@redhat.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:58361 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756755Ab3CYDh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:37:27 -0400
Received: by mail-pd0-f198.google.com with SMTP id 4so5230704pdd.5
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 20:37:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit d6a8c36dd6f6f06f046e5c61d3fb39b777c3bdc6.
Next commit makes this commit unnecessary.

CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/udp.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 3c362ee..7117d14 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2304,8 +2304,7 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	int mac_len = skb->mac_len;
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	int outer_hlen, id;
-	struct iphdr *iph;
+	int outer_hlen;
 	netdev_features_t enc_features;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
@@ -2316,8 +2315,6 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
-	iph = ip_hdr(skb);
-	id = ntohs(iph->id);
 
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
@@ -2332,8 +2329,6 @@ static struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 		int udp_offset = outer_hlen - tnl_hlen;
 
 		skb->mac_len = mac_len;
-		iph = (struct iphdr *)skb_inner_network_header(skb);
-		iph->id = htons(id++);
 
 		skb_push(skb, outer_hlen);
 		skb_reset_mac_header(skb);
-- 
1.7.1
