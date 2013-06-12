From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gro: remove a sparse error
Date: Wed, 12 Jun 2013 14:23:15 -0700
Message-ID: <1371072195.3252.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:65335 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755695Ab3FLVXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 17:23:19 -0400
Received: by mail-ee0-f50.google.com with SMTP id d49so4609293eek.23
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 14:23:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fix following sparse error :

net/ipv4/af_inet.c:1410:59: warning: restricted __be16 degrades to
integer

added in commit db8caf3dbc77599
("gro: should aggregate frames without DF")

Reported-by: kbuild test robot <fengguang.wu@intel.com>
From: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/af_inet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5598b06..b4d0be2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1407,7 +1407,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 		NAPI_GRO_CB(p)->flush |=
 			(iph->ttl ^ iph2->ttl) |
 			(iph->tos ^ iph2->tos) |
-			((iph->frag_off ^ iph2->frag_off) & htons(IP_DF)) |
+			(__force int)((iph->frag_off ^ iph2->frag_off) & htons(IP_DF)) |
 			((u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) ^ id);
 
 		NAPI_GRO_CB(p)->flush |= flush;
