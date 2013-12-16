From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 05/13] ah4: Export ah4_err
Date: Mon, 16 Dec 2013 10:21:42 +0100
Message-ID: <20131216092142.GV31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51889 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869Ab3LPJVo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:21:44 -0500
Content-Disposition: inline
In-Reply-To: <20131216091835.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah4_err can be shared with the upcomming vti ah handler.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ah.h |    2 ++
 net/ipv4/ah4.c   |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/ah.h b/include/net/ah.h
index ca95b98..6aa0f43 100644
--- a/include/net/ah.h
+++ b/include/net/ah.h
@@ -6,6 +6,8 @@
 /* This is the maximum truncated ICV length that we know of. */
 #define MAX_AH_AUTH_LEN	64
 
+int ah4_err(struct sk_buff *skb, u32 info);
+
 struct crypto_ahash;
 
 struct ah_data {
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index ea30e4e..4374671 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -397,7 +397,7 @@ out:
 	return err;
 }
 
-static int ah4_err(struct sk_buff *skb, u32 info)
+int ah4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
@@ -427,6 +427,7 @@ static int ah4_err(struct sk_buff *skb, u32 info)
 
 	return 0;
 }
+EXPORT_SYMBOL(ah4_err);
 
 static int ah_init_state(struct xfrm_state *x)
 {
-- 
1.7.9.5
