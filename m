From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: skbuff: Use ALIGN macro instead of open coding it
Date: Tue, 22 Jul 2014 12:06:23 +0200
Message-ID: <1406023583-25851-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:41420 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbaGVKKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 06:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ALIGN from linux/kernel.h to define SKB_DATA_ALIGN instead of open
coding it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 include/linux/skbuff.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3694303..b613557 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -112,8 +112,7 @@
 #define CHECKSUM_COMPLETE	2
 #define CHECKSUM_PARTIAL	3
 
-#define SKB_DATA_ALIGN(X)	(((X) + (SMP_CACHE_BYTES - 1)) & \
-				 ~(SMP_CACHE_BYTES - 1))
+#define SKB_DATA_ALIGN(X)	ALIGN(X, SMP_CACHE_BYTES)
 #define SKB_WITH_OVERHEAD(X)	\
 	((X) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 #define SKB_MAX_ORDER(X, ORDER) \
-- 
2.0.1
