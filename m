From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH v2] net: reallocate new socket option number for IPV6_AUTOFLOWLABEL
Date: Thu,  7 Aug 2014 00:17:09 +0200
Message-ID: <1407363429-3870-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	davej@redhat.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cb1ce2e ("ipv6: Implement automatic flow label generation on transmit")
accidentally uses socket option 64, which is already used by ip6tables:

 IP6T_SO_SET_REPLACE / IP6T_SO_GET_INFO               64
 IP6T_SO_SET_ADD_COUNTERS / IP6T_SO_GET_ENTRIES       65

There is comment include/uapi/linux/in6.h warning about that.

Allocate 70 for this, which seems to be unused instead.

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/in6.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
index 22b7a69..74a2a17 100644
--- a/include/uapi/linux/in6.h
+++ b/include/uapi/linux/in6.h
@@ -233,7 +233,6 @@ struct in6_flowlabel_req {
 #if 0	/* not yet */
 #define IPV6_USE_MIN_MTU	63
 #endif
-#define IPV6_AUTOFLOWLABEL	64
 
 /*
  * Netfilter (1)
@@ -262,6 +261,7 @@ struct in6_flowlabel_req {
  * IP6T_SO_ORIGINAL_DST		80
  */
 
+#define IPV6_AUTOFLOWLABEL	70
 /* RFC5014: Source address selection */
 #define IPV6_ADDR_PREFERENCES	72
 
-- 
1.7.10.4

