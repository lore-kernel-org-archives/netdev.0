From: Blair Steven <blair.steven@alliedtelesis.co.nz>
Subject: [PATCH] esp: correct offset for ESN when using NAT-T
Date: Mon, 13 Jun 2016 11:48:14 +1200
Message-ID: <20160612234814.15460-2-blair.steven@alliedtelesis.co.nz>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
Cc: Blair Steven <blair.steven@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:55089 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbcFLXsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 19:48:23 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 64C2A806CB
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 11:48:21 +1200 (NZST)
In-Reply-To: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offset for calculating ESN was not taking into account the new UDP
header created for NAT-T.
---
 net/ipv4/esp4.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4779374..c84d1fc 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -223,6 +223,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		uh->len = htons(skb->len - skb_transport_offset(skb));
 		uh->check = 0;
 
+		skb_set_transport_header(skb, skb_transport_offset(skb) + sizeof(struct udphdr));
+
 		switch (encap_type) {
 		default:
 		case UDP_ENCAP_ESPINUDP:
-- 
2.8.3
