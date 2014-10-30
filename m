From: Tom Herbert <therbert@google.com>
Subject: [PATCH net] gre: Use inner mac length when computing tunnel length
Date: Thu, 30 Oct 2014 08:40:56 -0700
Message-ID: <1414683656-26493-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:54248 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933861AbaJ3PlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:41:01 -0400
Received: by mail-pd0-f170.google.com with SMTP id z10so5363483pdj.15
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 08:41:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, skb_inner_network_header is used but this does not account
for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header which
handles TEB and also should work with IP encapsulation in which case
inner mac and inner network headers are the same.

Tested: Ran TCP_STREAM over GRE, worked as expected.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index f6e345c..bb5947b 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -47,7 +47,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 
-	ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
+	ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
 	if (unlikely(ghl < sizeof(*greh)))
 		goto out;
 
-- 
2.1.0.rc2.206.gedb03e5
