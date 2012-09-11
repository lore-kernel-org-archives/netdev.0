From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 1/2] ipv6: Add labels for site-local and 6bone testing
 addresses (RFC6724)
Date: Tue, 11 Sep 2012 13:16:49 +0900
Message-ID: <201209110508.q8B58GJO015601@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59723 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab2IKFWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 01:22:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added labels for site-local addresses (fec0::/10) and 6bone testing
addresses (3ffe::/16) in order to depreference them.

Note that the RFC introduced new rows for Teredo, ULA and 6to4 addresses
in the default policy table.  Some of them have different labels from ours.
For backward compatibility, we do not change the "default" labels.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrlabel.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 0b01715..4be23da 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -57,7 +57,7 @@ struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
 }
 
 /*
- * Default policy table (RFC3484 + extensions)
+ * Default policy table (RFC6724 + extensions)
  *
  * prefix		addr_type	label
  * -------------------------------------------------------------------------
@@ -69,8 +69,12 @@ struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
  * fc00::/7		N/A		5		ULA (RFC 4193)
  * 2001::/32		N/A		6		Teredo (RFC 4380)
  * 2001:10::/28		N/A		7		ORCHID (RFC 4843)
+ * fec0::/10		N/A		11		Site-local
+ *							(deprecated by RFC3879)
+ * 3ffe::/16		N/A		12		6bone
  *
  * Note: 0xffffffff is used if we do not have any policies.
+ * Note: Labels for ULA and 6to4 are different from labels listed in RFC6724.
  */
 
 #define IPV6_ADDR_LABEL_DEFAULT	0xffffffffUL
@@ -88,10 +92,18 @@ static const __net_initdata struct ip6addrlbl_init_table
 		.prefix = &(struct in6_addr){{{ 0xfc }}},
 		.prefixlen = 7,
 		.label = 5,
+	},{	/* fec0::/10 */
+		.prefix = &(struct in6_addr){{{ 0xfe, 0xc0 }}},
+		.prefixlen = 10,
+		.label = 11,
 	},{	/* 2002::/16 */
 		.prefix = &(struct in6_addr){{{ 0x20, 0x02 }}},
 		.prefixlen = 16,
 		.label = 2,
+	},{	/* 3ffe::/16 */
+		.prefix = &(struct in6_addr){{{ 0x3f, 0xfe }}},
+		.prefixlen = 16,
+		.label = 12,
 	},{	/* 2001::/32 */
 		.prefix = &(struct in6_addr){{{ 0x20, 0x01 }}},
 		.prefixlen = 32,
-- 
1.7.5.4
