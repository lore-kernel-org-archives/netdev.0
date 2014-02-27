From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] ip6_vti: Fix build when NET_IP_TUNNEL is not set.
Date: Thu, 27 Feb 2014 07:16:35 +0100
Message-ID: <1393481799-20492-2-git-send-email-steffen.klassert@secunet.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57433 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbaB0GQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:50 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 469bdcefdc47a ip6_vti uses ip_tunnel_get_stats64(),
so we need to select NET_IP_TUNNEL to have this function available.

Fixes: 469bdcefdc ("ipv6: fix the use of pcpu_tstats in ip6_vti.c")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index d92e558..438a73a 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -138,6 +138,7 @@ config INET6_XFRM_MODE_ROUTEOPTIMIZATION
 config IPV6_VTI
 tristate "Virtual (secure) IPv6: tunneling"
 	select IPV6_TUNNEL
+	select NET_IP_TUNNEL
 	depends on INET6_XFRM_MODE_TUNNEL
 	---help---
 	Tunneling means encapsulating data of one protocol type within
-- 
1.7.9.5
