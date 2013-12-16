From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 07/13] ipcomp4: Export ipcomp4_err
Date: Mon, 16 Dec 2013 10:23:02 +0100
Message-ID: <20131216092302.GX31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51937 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534Ab3LPJXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:23:05 -0500
Content-Disposition: inline
In-Reply-To: <20131216091835.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipcomp4_err can be shared with the upcomming vti ipcomp handler.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ipcomp.h |    1 +
 net/ipv4/ipcomp.c    |    3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/ipcomp.h b/include/net/ipcomp.h
index cc4f30c..c9021de 100644
--- a/include/net/ipcomp.h
+++ b/include/net/ipcomp.h
@@ -20,6 +20,7 @@ int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb);
 int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb);
 void ipcomp_destroy(struct xfrm_state *x);
 int ipcomp_init_state(struct xfrm_state *x);
+int ipcomp4_err(struct sk_buff *skb, u32 info);
 
 static inline struct ip_comp_hdr *ip_comp_hdr(const struct sk_buff *skb)
 {
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index c94d1c2..3a3404c 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -23,7 +23,7 @@
 #include <net/protocol.h>
 #include <net/sock.h>
 
-static int ipcomp4_err(struct sk_buff *skb, u32 info)
+int ipcomp4_err(struct sk_buff *skb, u32 info)
 {
 	struct net *net = dev_net(skb->dev);
 	__be32 spi;
@@ -55,6 +55,7 @@ static int ipcomp4_err(struct sk_buff *skb, u32 info)
 
 	return 0;
 }
+EXPORT_SYMBOL(ipcomp4_err);
 
 /* We always hold one tunnel user reference to indicate a tunnel */
 static struct xfrm_state *ipcomp_tunnel_create(struct xfrm_state *x)
-- 
1.7.9.5
