From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iproute2] iproute: print addrgenmode stable_secret and fallback otherwise
Date: Wed, 16 Dec 2015 10:52:36 +0100
Message-ID: <1450259556-14324-1-git-send-email-hannes@stressinduktion.org>
Cc: stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52233 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754638AbbLPJwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 04:52:43 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 91C1D20B51
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2015 04:52:42 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 ip/ipaddress.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index bc8359eb9fad6c..a495a391a0ecdb 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -285,13 +285,20 @@ static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
 	parse_rtattr_nested(tb, IFLA_INET6_MAX, inet6_attr);
 
 	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
-		switch (rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE])) {
+		__u8 mode = rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE]);
+		switch (mode) {
 		case IN6_ADDR_GEN_MODE_EUI64:
 			fprintf(fp, "addrgenmode eui64 ");
 			break;
 		case IN6_ADDR_GEN_MODE_NONE:
 			fprintf(fp, "addrgenmode none ");
 			break;
+		case IN6_ADDR_GEN_MODE_STABLE_PRIVACY:
+			fprintf(fp, "addrgenmode stable_secret ");
+			break;
+		default:
+			fprintf(fp, "addrgenmode %#.2hhx ", mode);
+			break;
 		}
 	}
 }
-- 
2.5.0
