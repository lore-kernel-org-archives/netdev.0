From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: napi_frags_skb() is static
Date: Sat, 19 May 2012 08:49:06 +0200
Message-ID: <1337410146.7029.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:54136 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439Ab2ESGtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:49:11 -0400
Received: by weyu7 with SMTP id u7so2207388wey.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 23:49:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

No need to export napi_frags_skb()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    1 -
 net/core/dev.c            |    3 +--
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c710bd..e7fd468 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2142,7 +2142,6 @@ extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb,
 					  gro_result_t ret);
-extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
 extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 
 static inline void napi_free_frags(struct napi_struct *napi)
diff --git a/net/core/dev.c b/net/core/dev.c
index 33684b6..cd09819 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3602,7 +3602,7 @@ gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(napi_frags_finish);
 
-struct sk_buff *napi_frags_skb(struct napi_struct *napi)
+static struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi->skb;
 	struct ethhdr *eth;
@@ -3637,7 +3637,6 @@ struct sk_buff *napi_frags_skb(struct napi_struct *napi)
 out:
 	return skb;
 }
-EXPORT_SYMBOL(napi_frags_skb);
 
 gro_result_t napi_gro_frags(struct napi_struct *napi)
 {
