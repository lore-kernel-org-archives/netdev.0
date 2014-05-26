From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: tso: Export symbols for modular build
Date: Mon, 26 May 2014 14:52:46 +0530
Message-ID: <1401096166-5409-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, ezequiel.garcia@free-electrons.com,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:65098 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbaEZJZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 05:25:08 -0400
Received: by mail-pb0-f50.google.com with SMTP id ma3so7429456pbc.23
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 02:25:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the symbols to fix the below errors when built as modules:
ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
ERROR: "tso_start" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mvneta.ko] undefined!
ERROR: "tso_build_data" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "tso_build_hdr" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "tso_start" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!
ERROR: "tso_count_descs" [drivers/net/ethernet/marvell/mv643xx_eth.ko] undefined!

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 net/core/tso.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/core/tso.c b/net/core/tso.c
index 097821dd3a8c..8c3203c585b0 100644
--- a/net/core/tso.c
+++ b/net/core/tso.c
@@ -1,3 +1,4 @@
+#include <linux/export.h>
 #include <net/ip.h>
 #include <net/tso.h>
 
@@ -7,6 +8,7 @@ int tso_count_descs(struct sk_buff *skb)
 	/* The Marvell Way */
 	return skb_shinfo(skb)->gso_segs * 2 + skb_shinfo(skb)->nr_frags;
 }
+EXPORT_SYMBOL(tso_count_descs);
 
 void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 		   int size, bool is_last)
@@ -31,6 +33,7 @@ void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
 		tcph->rst = 0;
 	}
 }
+EXPORT_SYMBOL(tso_build_hdr);
 
 void tso_build_data(struct sk_buff *skb, struct tso_t *tso, int size)
 {
@@ -48,6 +51,7 @@ void tso_build_data(struct sk_buff *skb, struct tso_t *tso, int size)
 		tso->next_frag_idx++;
 	}
 }
+EXPORT_SYMBOL(tso_build_data);
 
 void tso_start(struct sk_buff *skb, struct tso_t *tso)
 {
@@ -70,3 +74,4 @@ void tso_start(struct sk_buff *skb, struct tso_t *tso)
 		tso->next_frag_idx++;
 	}
 }
+EXPORT_SYMBOL(tso_start);
-- 
1.7.9.5
