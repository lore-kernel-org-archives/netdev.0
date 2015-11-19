From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove useless check in napi_gro_frags()
Date: Thu, 19 Nov 2015 11:42:50 -0800
Message-ID: <1447962170.22599.240.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35798 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755529AbbKSTmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:42:52 -0500
Received: by pacej9 with SMTP id ej9so90332815pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:42:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Checking if skb is NULL in napi_gro_frags() is too late.

If skb was NULL, we would crash earlier in napi_frags_skb()

Drivers normally catch napi_get_frags() NULL return value
before calling napi_gro_frags()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 41cef3e3f558b857a9093a83f6b0c73f32b8b45f..8d8d34ff68f5800dbcb2958b6a937b9db478e359 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4465,9 +4465,6 @@ gro_result_t napi_gro_frags(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi_frags_skb(napi);
 
-	if (!skb)
-		return GRO_DROP;
-
 	trace_napi_gro_frags_entry(skb);
 
 	return napi_frags_finish(napi, skb, dev_gro_receive(napi, skb));
