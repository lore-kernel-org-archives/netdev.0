From: James Morris <jmorris@namei.org>
Subject: [PATCH] dccp: remove module exit functions
Date: Fri, 10 Nov 2006 03:48:28 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611100345300.10983@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:52973 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1424383AbWKJIsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 03:48:31 -0500
To: acme@mandriva.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dccp ipv4 & ipv6 modules cannot be unloaded, as their control sockets 
each maintain a couple of module references.  So, it seems like a good 
idea to just remove the module exit functions completely.

Please review.

Signed-off-by: James Morris <jmorris@namei.org>

---

 net/dccp/ipv4.c |    8 --------
 net/dccp/ipv6.c |    8 --------
 2 files changed, 16 deletions(-)

diff -purN -X dontdiff linux-2.6.o/net/dccp/ipv4.c linux-2.6.w/net/dccp/ipv4.c
--- linux-2.6.o/net/dccp/ipv4.c	2006-10-27 01:52:53.000000000 -0400
+++ linux-2.6.w/net/dccp/ipv4.c	2006-11-10 03:10:34.000000000 -0500
@@ -1135,15 +1135,7 @@ out_proto_unregister:
 	goto out;
 }
 
-static void __exit dccp_v4_exit(void)
-{
-	inet_unregister_protosw(&dccp_v4_protosw);
-	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
-	proto_unregister(&dccp_v4_prot);
-}
-
 module_init(dccp_v4_init);
-module_exit(dccp_v4_exit);
 
 /*
  * __stringify doesn't likes enums, so use SOCK_DCCP (6) and IPPROTO_DCCP (33)
diff -purN -X dontdiff linux-2.6.o/net/dccp/ipv6.c linux-2.6.w/net/dccp/ipv6.c
--- linux-2.6.o/net/dccp/ipv6.c	2006-10-27 01:52:53.000000000 -0400
+++ linux-2.6.w/net/dccp/ipv6.c	2006-11-10 03:10:42.000000000 -0500
@@ -1276,15 +1276,7 @@ out_unregister_proto:
 	goto out;
 }
 
-static void __exit dccp_v6_exit(void)
-{
-	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
-	inet6_unregister_protosw(&dccp_v6_protosw);
-	proto_unregister(&dccp_v6_prot);
-}
-
 module_init(dccp_v6_init);
-module_exit(dccp_v6_exit);
 
 /*
  * __stringify doesn't likes enums, so use SOCK_DCCP (6) and IPPROTO_DCCP (33)
