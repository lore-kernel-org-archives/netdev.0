From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/4] net: fib6: reduce identation in ip6_convert_metrics
Date: Mon, 31 Aug 2015 15:58:45 +0200
Message-ID: <715e971e72a1a8cfc893000ad721ca58e2c1621c.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Cc: fw@strlen.de, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34937 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753286AbbHaN6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 09:58:53 -0400
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441027533.git.daniel@iogearbox.net>
References: <cover.1441027533.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the identation a bit, there's no need to artificically have
it increased.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/ipv6/route.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 308dd5f..0261b72 100644
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
1.9.3
