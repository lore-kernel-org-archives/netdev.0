From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 02/11] xfrm6_tunnel: join error paths using goto
Date: Sat, 13 Dec 2008 21:17:42 +0200
Message-ID: <12291958711089-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12291958711278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47975 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYLMTRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:17:54 -0500
In-Reply-To: <1229195871718-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/xfrm6_tunnel.c |   33 ++++++++++++++++-----------------
 1 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index c2b2781..80193db 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -345,24 +345,23 @@ static struct xfrm6_tunnel xfrm46_tunnel_handler =
=3D {
 static int __init xfrm6_tunnel_init(void)
 {
 	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0)
-		return -EAGAIN;
-
-	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6)) {
-		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return -EAGAIN;
-	}
-	if (xfrm6_tunnel_register(&xfrm46_tunnel_handler, AF_INET)) {
-		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
-		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return -EAGAIN;
-	}
-	if (xfrm6_tunnel_spi_init() < 0) {
-		xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
-		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
-		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-		return -EAGAIN;
-	}
+		goto err;
+	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6))
+		goto unreg;
+	if (xfrm6_tunnel_register(&xfrm46_tunnel_handler, AF_INET))
+		goto dereg6;
+	if (xfrm6_tunnel_spi_init() < 0)
+		goto dereg46;
 	return 0;
+
+dereg46:
+	xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
+dereg6:
+	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
+unreg:
+	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
+err:
+	return -EAGAIN;
 }
=20
 static void __exit xfrm6_tunnel_fini(void)
--=20
1.5.2.2

