From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net 1/3] Revert "ip_gre: increase inner ip header ID during segmentation"
Date: Sun, 24 Mar 2013 20:36:16 -0700
Message-ID: <1364182576-1700-1-git-send-email-pshelar@nicira.com>
Cc: amwang@redhat.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog111.obsmtp.com ([74.125.149.205]:36315 "HELO
	na3sys009aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756524Ab3CYDhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 23:37:20 -0400
Received: by mail-da0-f72.google.com with SMTP id q27so4336853daj.3
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 20:37:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 10c0d7ed32b7c273970a20e211c08ab46fea3c26.
Next commit makes this commit unnecessary.

CC: Cong Wang <amwang@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/gre.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index e20631c..7a4c710 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -125,9 +125,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	netdev_features_t enc_features;
 	int ghl = GRE_HEADER_SECTION;
 	struct gre_base_hdr *greh;
-	struct iphdr *iph;
 	int mac_len = skb->mac_len;
-	int tnl_hlen, id;
+	int tnl_hlen;
 	bool csum;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
@@ -171,8 +170,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb_set_network_header(skb, skb_inner_network_offset(skb));
 	skb->mac_len = skb_inner_network_offset(skb);
 
-	iph = ip_hdr(skb);
-	id = ntohs(iph->id);
 	/* segment inner packet. */
 	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
 	segs = skb_mac_gso_segment(skb, enc_features);
@@ -182,8 +179,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	tnl_hlen = skb_tnl_header_len(skb);
 	do {
-		iph = (struct iphdr *)skb->data;
-		iph->id = htons(id++);
 		__skb_push(skb, ghl);
 		if (csum) {
 			__be32 *pcsum;
-- 
1.7.1
