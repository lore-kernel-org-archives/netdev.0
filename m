From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 4/7]: Fix free_netdev after failed alloc_netdev in ipip_init
Date: Sun, 03 Oct 2004 23:13:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B62.8020303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010704060704000104070009"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010704060704000104070009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Same problem as in ip_gre:
Passing a NULL-ptr to free_netdev is wrong.



--------------010704060704000104070009
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:41:00+02:00 kaber@coreworks.de 
#   [IPV4]: Fix free_netdev after failed alloc_netdev in ipip_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/ipip.c
#   2004/10/03 20:40:18+02:00 kaber@coreworks.de +5 -4
#   [IPV4]: Fix free_netdev after failed alloc_netdev in ipip_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/ipip.c b/net/ipv4/ipip.c
--- a/net/ipv4/ipip.c	2004-10-03 22:20:28 +02:00
+++ b/net/ipv4/ipip.c	2004-10-03 22:20:28 +02:00
@@ -876,18 +876,19 @@
 					   ipip_tunnel_setup);
 	if (!ipip_fb_tunnel_dev) {
 		err = -ENOMEM;
-		goto fail;
+		goto err1;
 	}
 
 	ipip_fb_tunnel_dev->init = ipip_fb_tunnel_init;
 
 	if ((err = register_netdev(ipip_fb_tunnel_dev)))
-	    goto fail;
+		goto err2;
  out:
 	return err;
- fail:
-	xfrm4_tunnel_deregister(&ipip_handler);
+ err2:
 	free_netdev(ipip_fb_tunnel_dev);
+ err1:
+	xfrm4_tunnel_deregister(&ipip_handler);
 	goto out;
 }
 

--------------010704060704000104070009--
