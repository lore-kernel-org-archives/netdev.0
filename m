From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] route: Use the device mtu as the default for blackhole
 routes
Date: Wed, 23 Nov 2011 13:12:13 +0100
Message-ID: <20111123121213.GA6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53422 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181Ab1KWMMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 07:12:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As it is, we return null as the default mtu of blackhole routes.
This may lead to a propagation of a bogus pmtu if the default_mtu
method of a blackhole route is invoked. So return dst->dev->mtu
as the default mtu instead.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    2 +-
 net/ipv6/route.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0c74da8..5b17bf1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2757,7 +2757,7 @@ static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 coo
 
 static unsigned int ipv4_blackhole_default_mtu(const struct dst_entry *dst)
 {
-	return 0;
+	return dst->dev->mtu;
 }
 
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8473016..d8fbd18 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -157,7 +157,7 @@ static struct dst_ops ip6_dst_ops_template = {
 
 static unsigned int ip6_blackhole_default_mtu(const struct dst_entry *dst)
 {
-	return 0;
+	return dst->dev->mtu;
 }
 
 static void ip6_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
-- 
1.7.0.4
