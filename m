From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: sit: ensure prefixlen <= 128 before calling ipv6_addr_prefix
Date: Sun, 29 Sep 2013 05:15:35 +0200
Message-ID: <20130929031535.GA8602@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57830 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753466Ab3I2DPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 23:15:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found with coverity: CID 139492

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7ee5cb9..4011178 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1004,6 +1004,9 @@ static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 	    ip6rd->prefixlen + (32 - ip6rd->relay_prefixlen) > 64)
 		return -EINVAL;
 
+	if (ip6rd->prefixlen > 128)
+		return -EINVAL;
+
 	ipv6_addr_prefix(&prefix, &ip6rd->prefix, ip6rd->prefixlen);
 	if (!ipv6_addr_equal(&prefix, &ip6rd->prefix))
 		return -EINVAL;
-- 
1.8.3.1
