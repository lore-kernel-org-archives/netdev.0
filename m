From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ipv6: Fix endianess warning in ip6_flow_hdr().
Date: Thu, 17 Jan 2013 12:10:57 +0900
Message-ID: <50F76BC1.90300@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43481 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758750Ab3AQDK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:10:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3e4e4c1f ("ipv6: Introduce ip6_flow_hdr() to fill version,
tclass and flowlabel.) uses ntohl(), which should be htonl().

Found by Fengguang Wu <fengguang.wu@intel.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 459a5a4..be3358b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -629,7 +629,7 @@ extern void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
 static inline void ip6_flow_hdr(struct ipv6hdr *hdr, unsigned int tclass,
 				__be32 flowlabel)
 {
-	*(__be32 *)hdr = ntohl(0x60000000 | (tclass << 20)) | flowlabel;
+	*(__be32 *)hdr = htonl(0x60000000 | (tclass << 20)) | flowlabel;
 }
 
 static inline __be32 ip6_flowinfo(const struct ipv6hdr *hdr)
-- 
1.7.9.5
