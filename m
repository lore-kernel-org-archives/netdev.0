From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6.9]: Fix inet6_dev reference leak in ndisc_dst_alloc error
 path
Date: Wed, 20 Oct 2004 00:02:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41758EF7.6010906@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050200080904090303050100"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050200080904090303050100
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

ndisc_dst_alloc leaks a inet6_dev reference when ip6_dst_alloc
returns NULL. The bug was introduced somewhere between 2.6.8
and 2.6.9.

Regards
Patrick




--------------050200080904090303050100
Content-Type: text/plain;
 name="p1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="p1"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 23:13:24+02:00 kaber@coreworks.de 
#   [IPV6]: Fix inet6_dev reference leak in ndisc_dst_alloc error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/ipv6/route.c
#   2004/10/19 23:12:48+02:00 kaber@coreworks.de +3 -1
#   [IPV6]: Fix inet6_dev reference leak in ndisc_dst_alloc error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2004-10-19 23:51:11 +02:00
+++ b/net/ipv6/route.c	2004-10-19 23:51:11 +02:00
@@ -647,8 +647,10 @@
 		return NULL;
 
 	rt = ip6_dst_alloc();
-	if (unlikely(rt == NULL))
+	if (unlikely(rt == NULL)) {
+		in6_dev_put(idev);
 		goto out;
+	}
 
 	dev_hold(dev);
 	if (neigh)

--------------050200080904090303050100--
