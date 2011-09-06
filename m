From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 1/2] net: Align AF-specific flowi structs to long
Date: Mon, 5 Sep 2011 22:47:23 -0400
Message-ID: <1315277244-19335-2-git-send-email-david.ward@ll.mit.edu>
References: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:60536 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751935Ab1IFDLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 23:11:24 -0400
In-Reply-To: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

AF-specific flowi structs are now passed to flow_key_compare, which must
also be aligned to a long.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/net/flow.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 78113da..2ec377d 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -68,7 +68,7 @@ struct flowi4 {
 #define fl4_ipsec_spi		uli.spi
 #define fl4_mh_type		uli.mht.type
 #define fl4_gre_key		uli.gre_key
-};
+} __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 				      __u32 mark, __u8 tos, __u8 scope,
@@ -112,7 +112,7 @@ struct flowi6 {
 #define fl6_ipsec_spi		uli.spi
 #define fl6_mh_type		uli.mht.type
 #define fl6_gre_key		uli.gre_key
-};
+} __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 struct flowidn {
 	struct flowi_common	__fl_common;
@@ -127,7 +127,7 @@ struct flowidn {
 	union flowi_uli		uli;
 #define fld_sport		uli.ports.sport
 #define fld_dport		uli.ports.dport
-};
+} __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 struct flowi {
 	union {
-- 
1.7.1
