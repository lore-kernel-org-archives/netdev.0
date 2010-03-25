From: kaber@trash.net
Subject: [PATCH 4/4] netfilter: xt_hashlimit: IPV6 bugfix
Date: Thu, 25 Mar 2010 18:54:46 +0100
Message-ID: <1269539686-3885-5-git-send-email-kaber@trash.net>
References: <1269539686-3885-1-git-send-email-kaber@trash.net>
 <1269539686-3885-2-git-send-email-kaber@trash.net>
 <1269539686-3885-3-git-send-email-kaber@trash.net>
 <1269539686-3885-4-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56926 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462Ab0CYRyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:54:51 -0400
In-Reply-To: <1269539686-3885-4-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

A missing break statement in hashlimit_ipv6_mask(), and masks
between /64 and /95 are not working at all...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_hashlimit.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 70d561a..215a648 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -493,6 +493,7 @@ static void hashlimit_ipv6_mask(__be32 *i, unsigned int p)
 	case 64 ... 95:
 		i[2] = maskl(i[2], p - 64);
 		i[3] = 0;
+		break;
 	case 96 ... 127:
 		i[3] = maskl(i[3], p - 96);
 		break;
-- 
1.6.5.7

