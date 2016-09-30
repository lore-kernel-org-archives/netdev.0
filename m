From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 2/3] mpls: move mpls_hdr to a common location
Date: Fri, 30 Sep 2016 19:08:06 +0200
Message-ID: <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
References: <cover.1475255100.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932539AbcI3RJF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Sep 2016 13:09:05 -0400
In-Reply-To: <cover.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be also used by openvswitch.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: new in v2
---
 include/net/mpls.h  |  9 +++++++++
 net/mpls/internal.h | 10 +---------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/include/net/mpls.h b/include/net/mpls.h
index 5b3b5addfb08..3ebbc0bb57ff 100644
--- a/include/net/mpls.h
+++ b/include/net/mpls.h
@@ -19,12 +19,21 @@
 
 #define MPLS_HLEN 4
 
+struct mpls_shim_hdr {
+	__be32 label_stack_entry;
+};
+
 static inline bool eth_p_mpls(__be16 eth_type)
 {
 	return eth_type == htons(ETH_P_MPLS_UC) ||
 		eth_type == htons(ETH_P_MPLS_MC);
 }
 
+static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
+{
+	return (struct mpls_shim_hdr *)skb_network_header(skb);
+}
+
 /*
  * For non-MPLS skbs this will correspond to the network header.
  * For MPLS skbs it will be before the network_header as the MPLS
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 732a5c17e986..bdfef6c3271a 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -1,9 +1,6 @@
 #ifndef MPLS_INTERNAL_H
 #define MPLS_INTERNAL_H
-
-struct mpls_shim_hdr {
-	__be32 label_stack_entry;
-};
+#include <net/mpls.h>
 
 struct mpls_entry_decoded {
 	u32 label;
@@ -93,11 +90,6 @@ struct mpls_route { /* next hop label forwarding entry */
 
 #define endfor_nexthops(rt) }
 
-static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
-{
-	return (struct mpls_shim_hdr *)skb_network_header(skb);
-}
-
 static inline struct mpls_shim_hdr mpls_entry_encode(u32 label, unsigned ttl, unsigned tc, bool bos)
 {
 	struct mpls_shim_hdr result;
-- 
1.8.3.1
