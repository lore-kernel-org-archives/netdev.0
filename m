From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Fix skb leak in igmpv3_newpack
Date: Fri, 28 May 2004 12:54:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B71A62.6050008@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080406080103060508000105"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080406080103060508000105
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an skb-leak in igmpv3_newpack. skb isn't
freed when rt->rt_src == 0. Patch applies to 2.4 and 2.6.

Regards
Patrick

--------------080406080103060508000105
Content-Type: text/x-patch;
 name="igmpv3_newpack-skbleak.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="igmpv3_newpack-skbleak.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/05/28 12:30:41+02:00 kaber@trash.net 
#   [IPV4]: Fix skb leak in igmpv3_newpack
# 
# net/ipv4/igmp.c
#   2004/05/28 12:30:34+02:00 kaber@trash.net +1 -0
#   [IPV4]: Fix skb leak in igmpv3_newpack
# 
diff -Nru a/net/ipv4/igmp.c b/net/ipv4/igmp.c
--- a/net/ipv4/igmp.c	2004-05-28 12:35:28 +02:00
+++ b/net/ipv4/igmp.c	2004-05-28 12:35:28 +02:00
@@ -292,6 +292,7 @@
 		}
 	}
 	if (rt->rt_src == 0) {
+		kfree_skb(skb);
 		ip_rt_put(rt);
 		return 0;
 	}

--------------080406080103060508000105--
