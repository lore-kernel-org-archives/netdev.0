From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 6/7]: Fix free_netdev after failed alloc_netdev in sit_init
Date: Sun, 03 Oct 2004 23:13:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B7A.2080101@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080500050102080509080405"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080500050102080509080405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Same problem as in ip_gre.c and ipip.c:
Passing a NULL-ptr to free_netdev is wrong.



--------------080500050102080509080405
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:43:32+02:00 kaber@coreworks.de 
#   [IPV6]: Fix free_netdev after failed alloc_netdev in sit_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/sit.c
#   2004/10/03 20:43:09+02:00 kaber@coreworks.de +5 -4
#   [IPV6]: Fix free_netdev after failed alloc_netdev in sit_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv6/sit.c b/net/ipv6/sit.c
--- a/net/ipv6/sit.c	2004-10-03 22:21:06 +02:00
+++ b/net/ipv6/sit.c	2004-10-03 22:21:06 +02:00
@@ -814,18 +814,19 @@
 					   ipip6_tunnel_setup);
 	if (!ipip6_fb_tunnel_dev) {
 		err = -ENOMEM;
-		goto fail;
+		goto err1;
 	}
 
 	ipip6_fb_tunnel_dev->init = ipip6_fb_tunnel_init;
 
 	if ((err =  register_netdev(ipip6_fb_tunnel_dev)))
-		goto fail;
+		goto err2;
 
  out:
 	return err;
- fail:
-	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
+ err2:
 	free_netdev(ipip6_fb_tunnel_dev);
+ err1:
+	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
 	goto out;
 }

--------------080500050102080509080405--
