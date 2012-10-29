From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] ipv6: remove another useless NULL check
Date: Mon, 29 Oct 2012 16:16:25 +0800
Message-ID: <1351498585-20087-1-git-send-email-amwang@redhat.com>
References: <1351491005.7394.7.camel@edumazet-glaptop>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754804Ab2J2IQm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 04:16:42 -0400
In-Reply-To: <1351491005.7394.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When 'rt' is NULL, '&rt->dst' is NULL too because >dst
is always the first field of 'rt'. And dst_release accepts
NULL.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8f0b12a..adeb479 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2027,8 +2027,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
 					      dev, expires, flags);
 		}
-		if (rt)
-			dst_release(&rt->dst);
+		dst_release(&rt->dst);
 	}
 
 	/* Try to figure out our local address for this prefix */
