From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/10] netfilter: nf_nat: missing condition in nf_xfrm_me_harder()
Date: Thu, 25 Apr 2013 02:22:21 +0200
Message-ID: <1366849341-10466-11-git-send-email-pablo@netfilter.org>
References: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41146 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab3DYAWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 20:22:41 -0400
In-Reply-To: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

This if statement was accidentally dropped in (aaa795a netfilter:
nat: propagate errors from xfrm_me_harder()) so now it returns
unconditionally.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 346f871..cf1c731 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -90,6 +90,7 @@ int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 	int err;
 
 	err = xfrm_decode_session(skb, &fl, family);
+	if (err < 0)
 		return err;
 
 	dst = skb_dst(skb);
-- 
1.7.10.4
