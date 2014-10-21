From: "Alexey Andriyanov" <alan@al-an.info>
Subject: [net-next 1/2] ip6_tunnel: put ip6tnl0 FB device into 'any' mode
Date: Tue, 21 Oct 2014 12:19:55 +0400
Message-ID: <1413879596-13726-1-git-send-email-alan@al-an.info>
Cc: Alexey Andriyanov <alan@al-an.info>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Roman Gushchin <klamm@yandex-team.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6l.mail.yandex.net ([84.201.143.139]:44335 "EHLO
	forward6l.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbaJUIUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 04:20:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fallback device is in ipv6 mode by default.
The mode can not be changed in runtime, so there
is no way to decapsulate ip4in6 packets coming from
various sources without creating the specific tunnel
ifaces for each peer.

Cc: David Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexey Andriyanov <alan@al-an.info>
---
 net/ipv6/ip6_tunnel.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 9409887..a48f212 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1551,7 +1551,8 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 	if (err)
 		return err;
 
-	t->parms.proto = IPPROTO_IPV6;
+	/* allow any registered unrelying proto for the FB device */
+	t->parms.proto = 0;
 	dev_hold(dev);
 
 	ip6_tnl_link_config(t);
-- 
1.9.1
