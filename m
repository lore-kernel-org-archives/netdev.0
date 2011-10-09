From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] gro: refetch inet6_protos[] after pulling ext headers
Date: Sun, 09 Oct 2011 16:34:35 +0800
Message-ID: <4E915C9B.4000807@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13253 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751659Ab1JIIej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 04:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_gro_receive() doesn't update the protocol ops after pulling
the ext headers. It looks like a typo.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
---
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3b5669a..d27c797 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -875,6 +875,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		skb_reset_transport_header(skb);
 		__skb_push(skb, skb_gro_offset(skb));
 
+		ops = rcu_dereference(inet6_protos[proto]);
 		if (!ops || !ops->gro_receive)
 			goto out_unlock;
 
