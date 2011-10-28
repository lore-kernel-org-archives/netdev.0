From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv6: fix error propagation in ip6_ufo_append_data()
Date: Fri, 28 Oct 2011 12:24:20 +0800
Message-ID: <4EAA2E74.2000703@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61759 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834Ab1J1EYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 00:24:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should return errcode from sock_alloc_send_skb()

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ff30047..84d0bd5 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1123,7 +1123,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 			hh_len + fragheaderlen + transhdrlen + 20,
 			(flags & MSG_DONTWAIT), &err);
 		if (skb == NULL)
-			return -ENOMEM;
+			return err;
 
 		/* reserve space for Hardware header */
 		skb_reserve(skb, hh_len);
