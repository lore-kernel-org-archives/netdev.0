From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 1/4] netns xfrm: fixup xfrm6_tunnel error propagation
Date: Mon, 25 Jan 2010 22:28:21 +0200
Message-ID: <20100125202820.GA4482@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:44149 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852Ab0AYU21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 15:28:27 -0500
Received: by fxm20 with SMTP id 20so3995737fxm.21
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 12:28:26 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv6/xfrm6_tunnel.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -353,13 +353,19 @@ static struct xfrm6_tunnel xfrm46_tunnel_handler = {
 
 static int __init xfrm6_tunnel_init(void)
 {
-	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0)
+	int rv;
+
+	rv = xfrm_register_type(&xfrm6_tunnel_type, AF_INET6);
+	if (rv < 0)
 		goto err;
-	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6))
+	rv = xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6);
+	if (rv < 0)
 		goto unreg;
-	if (xfrm6_tunnel_register(&xfrm46_tunnel_handler, AF_INET))
+	rv = xfrm6_tunnel_register(&xfrm46_tunnel_handler, AF_INET);
+	if (rv < 0)
 		goto dereg6;
-	if (xfrm6_tunnel_spi_init() < 0)
+	rv = xfrm6_tunnel_spi_init();
+	if (rv < 0)
 		goto dereg46;
 	return 0;
 
@@ -370,7 +376,7 @@ dereg6:
 unreg:
 	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 err:
-	return -EAGAIN;
+	return rv;
 }
 
 static void __exit xfrm6_tunnel_fini(void)
