From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 2/3] net: fib6: reduce identation in ip6_convert_metrics
Date: Fri, 28 Aug 2015 14:11:08 +0200
Message-ID: <1440763869-23067-3-git-send-email-fw@strlen.de>
References: <1440763869-23067-1-git-send-email-fw@strlen.de>
Cc: Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57667 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbbH1MLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 08:11:20 -0400
In-Reply-To: <1440763869-23067-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

Reduce the identation a bit, there's no need to artificically have
it increased.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/ipv6/route.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index df3e353..56b2e71 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1711,26 +1711,26 @@ static int ip6_convert_metrics(struct mx6_config *mxc,
 
 	nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
 		int type = nla_type(nla);
+		u32 val;
 
-		if (type) {
-			u32 val;
-
-			if (unlikely(type > RTAX_MAX))
-				goto err;
-			if (type == RTAX_CC_ALGO) {
-				char tmp[TCP_CA_NAME_MAX];
+		if (!type)
+			continue;
+		if (unlikely(type > RTAX_MAX))
+			goto err;
 
-				nla_strlcpy(tmp, nla, sizeof(tmp));
-				val = tcp_ca_get_key_by_name(tmp);
-				if (val == TCP_CA_UNSPEC)
-					goto err;
-			} else {
-				val = nla_get_u32(nla);
-			}
+		if (type == RTAX_CC_ALGO) {
+			char tmp[TCP_CA_NAME_MAX];
 
-			mp[type - 1] = val;
-			__set_bit(type - 1, mxc->mx_valid);
+			nla_strlcpy(tmp, nla, sizeof(tmp));
+			val = tcp_ca_get_key_by_name(tmp);
+			if (val == TCP_CA_UNSPEC)
+				goto err;
+		} else {
+			val = nla_get_u32(nla);
 		}
+
+		mp[type - 1] = val;
+		__set_bit(type - 1, mxc->mx_valid);
 	}
 
 	mxc->mx = mp;
-- 
2.0.5
