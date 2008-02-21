From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Subject: [PATCH 1/2] [IPV6]: Add ORCHID prefix to address label table
Date: Thu, 21 Feb 2008 12:08:14 +0200
Message-ID: <20080221100813.GA24291@verkkotelakka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from refraktori.verkkotelakka.net ([79.171.233.68]:56553 "EHLO
	refraktori.verkkotelakka.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753433AbYBUKiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 05:38:04 -0500
Received: from jmtapio sender auth=jmtapio
	by refraktori.verkkotelakka.net with local (Exim 4.63) id 1JS8Le-0006ob-3N
	for netdev@vger.kernel.org; Thu, 21 Feb 2008 12:08:14 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new label for Overlay Routable Cryptographic Hash Identifiers
(RFC 4843) prefix 2001:10::/28 to help proper source address
selection.

ORCHID addresses are used by for example Host Identity Protocol. They are 
global and routable, but they currently need support from both endpoints 
and therefore mixing regular and ORCHID addresses for source and 
destination is a bad idea in general case.

Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
---
 net/ipv6/addrlabel.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index a3c5a72..3a8b3f5 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -58,6 +58,7 @@ static struct ip6addrlbl_table
  * ::ffff:0:0/96	V4MAPPED	4
  * fc00::/7		N/A		5		ULA (RFC 4193)
  * 2001::/32		N/A		6		Teredo (RFC 4380)
+ * 2001:10::/28		N/A		7		ORCHID (RFC 4843)
  *
  * Note: 0xffffffff is used if we do not have any policies.
  */
@@ -85,6 +86,10 @@ static const __initdata struct ip6addrlbl_init_table
 		.prefix = &(struct in6_addr){{{ 0x20, 0x01 }}},
 		.prefixlen = 32,
 		.label = 6,
+	},{	/* 2001:10::/28 */
+		.prefix = &(struct in6_addr){{{ 0x20, 0x01, 0x00, 0x10 }}},
+		.prefixlen = 28,
+		.label = 7,
 	},{	/* ::ffff:0:0 */
 		.prefix = &(struct in6_addr){{{ [10] = 0xff, [11] = 0xff }}},
 		.prefixlen = 96,
-- 
1.5.3.8

