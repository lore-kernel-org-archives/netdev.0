From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] sit: remove unnecessary protocol check in ipip6_tunnel_xmit()
Date: Thu,  9 Jun 2016 18:03:34 +0900
Message-ID: <1465463014-24169-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36461 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161019AbcFIJDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 05:03:46 -0400
Received: by mail-pf0-f175.google.com with SMTP id t190so11610215pfb.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 02:03:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipip6_tunnel_xmit() is called immediately after checking that
skb->protocol is  htons(ETH_P_IPV6) so there is no need
to check it a second time.

Found by inspection.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 This patch is targeted at upstream kernel "net-next" as a trivial fix.
 Please review.

 net/ipv6/sit.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0a5a255277e5..d9f2bd6ef72d 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -825,9 +825,6 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	u8 protocol = IPPROTO_IPV6;
 	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
-	if (skb->protocol != htons(ETH_P_IPV6))
-		goto tx_error;
-
 	if (tos == 1)
 		tos = ipv6_get_dsfield(iph6);
 
-- 
2.1.4
