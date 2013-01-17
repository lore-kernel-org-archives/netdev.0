From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] ipv4: Remove output route check in ipv4_mtu
Date: Thu, 17 Jan 2013 07:55:01 +0100
Message-ID: <20130117065500.GG18940@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, timo.teras@iki.fi,
	luky-37@hotmail.com, pupilla@libero.it, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53740 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751908Ab3AQGzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 01:55:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The output route check was introduced with git commit 261663b0
(ipv4: Don't use the cached pmtu informations for input routes)
during times when we cached the pmtu informations on the
inetpeer. Now the pmtu informations are back in the routes,
so this check is obsolete. It also had some unwanted side effects,
as reported by Timo Teras and Lukas Tribus.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 844a9ef..6e4a89c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1120,7 +1120,7 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 	if (!mtu || time_after_eq(jiffies, rt->dst.expires))
 		mtu = dst_metric_raw(dst, RTAX_MTU);
 
-	if (mtu && rt_is_output_route(rt))
+	if (mtu)
 		return mtu;
 
 	mtu = dst->dev->mtu;
-- 
1.7.9.5
