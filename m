From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 3/7]: Fix free_netdev after failed alloc_netdev in ipgre_init
Date: Sun, 03 Oct 2004 23:12:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B59.5020502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010601070104040304020902"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010601070104040304020902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Passing a NULL-ptr to free_netdev is wrong.



--------------010601070104040304020902
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:39:25+02:00 kaber@coreworks.de 
#   [IPV4]: Fix free_netdev after failed alloc_netdev in ipgre_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv4/ip_gre.c
#   2004/10/03 20:38:45+02:00 kaber@coreworks.de +6 -5
#   [IPV4]: Fix free_netdev after failed alloc_netdev in ipgre_init
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
--- a/net/ipv4/ip_gre.c	2004-10-03 22:19:31 +02:00
+++ b/net/ipv4/ip_gre.c	2004-10-03 22:19:31 +02:00
@@ -1250,7 +1250,7 @@
 
 static int __init ipgre_init(void)
 {
-	int err = -EINVAL;
+	int err;
 
 	printk(KERN_INFO "GRE over IPv4 tunneling driver\n");
 
@@ -1263,18 +1263,19 @@
 					   ipgre_tunnel_setup);
 	if (!ipgre_fb_tunnel_dev) {
 		err = -ENOMEM;
-		goto fail;
+		goto err1;
 	}
 
 	ipgre_fb_tunnel_dev->init = ipgre_fb_tunnel_init;
 
 	if ((err = register_netdev(ipgre_fb_tunnel_dev)))
-		goto fail;
+		goto err2;
 out:
 	return err;
-fail:
-	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+err2:
 	free_netdev(ipgre_fb_tunnel_dev);
+err1:
+	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
 	goto out;
 }
 

--------------010601070104040304020902--
