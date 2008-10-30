From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 3/3] netlabel: Fix compilation warnings in
	net/netlabel/netlabel_addrlist.c
Date: Thu, 30 Oct 2008 13:10:31 -0400
Message-ID: <20081030171031.11396.12192.stgit@flek.lan>
References: <20081030170736.11396.46099.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:12806 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758135AbYJ3RKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 13:10:34 -0400
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g5t0006.atlanta.hp.com (Postfix) with ESMTP id 540D5C196
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 17:10:33 +0000 (UTC)
In-Reply-To: <20081030170736.11396.46099.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Katiyar <mkatiyar@gmail.com>

Enable netlabel auditing functions only when CONFIG_AUDIT is set

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_addrlist.c |    2 ++
 net/netlabel/netlabel_addrlist.h |   22 ++++++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/net/netlabel/netlabel_addrlist.c b/net/netlabel/netlabel_addrlist.c
index b0925a3..249f6b9 100644
--- a/net/netlabel/netlabel_addrlist.c
+++ b/net/netlabel/netlabel_addrlist.c
@@ -315,6 +315,7 @@ struct netlbl_af6list *netlbl_af6list_remove(const struct in6_addr *addr,
  * Audit Helper Functions
  */
 
+#ifdef CONFIG_AUDIT
 /**
  * netlbl_af4list_audit_addr - Audit an IPv4 address
  * @audit_buf: audit buffer
@@ -386,3 +387,4 @@ void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 	}
 }
 #endif /* IPv6 */
+#endif /* CONFIG_AUDIT */
diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index 0242bea..07ae7fd 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -120,9 +120,19 @@ struct netlbl_af4list *netlbl_af4list_search(__be32 addr,
 struct netlbl_af4list *netlbl_af4list_search_exact(__be32 addr,
 						   __be32 mask,
 						   struct list_head *head);
+
+#ifdef CONFIG_AUDIT
 void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
 			       int src, const char *dev,
 			       __be32 addr, __be32 mask);
+#else
+static inline void netlbl_af4list_audit_addr(struct audit_buffer *audit_buf,
+					     int src, const char *dev,
+					     __be32 addr, __be32 mask)
+{
+	return;
+}
+#endif
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
@@ -179,11 +189,23 @@ struct netlbl_af6list *netlbl_af6list_search(const struct in6_addr *addr,
 struct netlbl_af6list *netlbl_af6list_search_exact(const struct in6_addr *addr,
 						   const struct in6_addr *mask,
 						   struct list_head *head);
+
+#ifdef CONFIG_AUDIT
 void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
 			       int src,
 			       const char *dev,
 			       const struct in6_addr *addr,
 			       const struct in6_addr *mask);
+#else
+static inline void netlbl_af6list_audit_addr(struct audit_buffer *audit_buf,
+					     int src,
+					     const char *dev,
+					     const struct in6_addr *addr,
+					     const struct in6_addr *mask)
+{
+	return;
+}
+#endif
 #endif /* IPV6 */
 
 #endif

