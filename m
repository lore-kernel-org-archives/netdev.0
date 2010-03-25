From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] xt_hashlimit: IPV6 bugfix
Date: Thu, 25 Mar 2010 17:17:49 +0100
Message-ID: <1269533869.3626.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A missing break statement in hashlimit_ipv6_mask(), and masks
between /64 and /95 are not working at all...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 8f3e0c0..7ac6ea7 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -487,6 +487,7 @@ static void hashlimit_ipv6_mask(__be32 *i, unsigned int p)
 	case 64 ... 95:
 		i[2] = maskl(i[2], p - 64);
 		i[3] = 0;
+		break;
 	case 96 ... 127:
 		i[3] = maskl(i[3], p - 96);
 		break;


