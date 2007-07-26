From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 6/6] [IPV6]: Remove circular dependency on if_inet6.h
Date: Thu, 26 Jul 2007 17:09:40 +0800
Message-ID: <E1IDzLo-0000AX-00@gondolin.me.apana.org.au>
References: <20070726090725.GA510@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1325 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759416AbXGZJJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 05:09:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Remove circular dependency on if_inet6.h

net/if_inet6.h includes linux/ipv6.h which also tries to include
net/if_inet6.h.  Since the latter only needs it for forward
declarations, we can fix this by adding the declarations.

A number of files are implicitly including net/if_inet6.h through
linux/ipv6.h.  They also use net/ipv6.h so this patch includes
net/if_inet6.h there.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/ipv6.h |    5 ++++-
 include/net/ipv6.h   |    1 +
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 97983dc..4ca60c3 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -219,7 +219,6 @@ enum {
 #include <linux/tcp.h>
 #include <linux/udp.h>
 
-#include <net/if_inet6.h>       /* struct ipv6_mc_socklist */
 #include <net/inet_sock.h>
 
 static inline struct ipv6hdr *ipv6_hdr(const struct sk_buff *skb)
@@ -273,6 +272,10 @@ struct tcp6_request_sock {
 	struct inet6_request_sock tcp6rsk_inet6;
 };
 
+struct ipv6_mc_socklist;
+struct ipv6_ac_socklist;
+struct ipv6_fl_socklist;
+
 /**
  * struct ipv6_pinfo - ipv6 private area
  *
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 46b9dce..9059e0e 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -17,6 +17,7 @@
 
 #include <linux/ipv6.h>
 #include <linux/hardirq.h>
+#include <net/if_inet6.h>
 #include <net/ndisc.h>
 #include <net/flow.h>
 #include <net/snmp.h>
