From: Jan Seiffert <kaffeemonster@googlemail.com>
Subject: [REGRESSION][PATCH V4 1/3] bpf jit: Make the filter.c::__load_pointer
 helper non-static  for the jits
Date: Fri, 30 Mar 2012 17:08:19 +0200
Message-ID: <4F75CC63.10405@googlemail.com>
References: <4F75CA89.4010709@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	"Matt Evans" <matt@ozlabs.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uhura.skim.hs-owl.de ([193.174.118.81]:58072 "EHLO
	uhura.skim.hs-owl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054Ab2C3QyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 12:54:16 -0400
In-Reply-To: <4F75CA89.4010709@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function is renamed to make it a little more clear what it does.
It is not added to any .h because it is not for general consumption, only for
bpf internal use (and so by the jits).

Signed-of-by: Jan Seiffert <kaffeemonster@googlemail.com>

--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -40,8 +40,12 @@
 #include <linux/reciprocal_div.h>
 #include <linux/ratelimit.h>
 
-/* No hurry in this branch */
-static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
+/*
+ * No hurry in this branch
+ *
+ * Exported for the bpf jit load helper.
+ */
+void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
 {
 	u8 *ptr = NULL;
 
@@ -60,7 +64,7 @@ static inline void *load_pointer(const struct sk_buff *skb, int k,
 {
 	if (k >= 0)
 		return skb_header_pointer(skb, k, size, buffer);
-	return __load_pointer(skb, k, size);
+	return bpf_internal_load_pointer_neg_helper(skb, k, size);
 }
 
 /**
