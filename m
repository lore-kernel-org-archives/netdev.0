From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH] IPv6 MIB:ipv6DefaultRouterTable
Date: Wed, 14 Jan 2004 16:22:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401141622.09299.mashirle@us.ibm.com>
References: <200311191621.38087.mashirle@us.ibm.com> <200312051351.47962.mashirle@us.ibm.com> <20031205145700.120e9e68.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_X09IDHM9YSKWUPJ5TXOR"
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031205145700.120e9e68.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--------------Boundary-00=_X09IDHM9YSKWUPJ5TXOR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

This patch is agaist 2.6.1 kernel.

Thanks
Shirley Ma
IBM Linux Technology Center



--------------Boundary-00=_X09IDHM9YSKWUPJ5TXOR
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="linux-2.6.1-ipv6mib7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="linux-2.6.1-ipv6mib7.patch"

diff -urN linux-2.6.1/include/linux/rtnetlink.h linux-2.6.1-ipv6mib7/include/linux/rtnetlink.h
--- linux-2.6.1/include/linux/rtnetlink.h	2004-01-08 22:59:55.000000000 -0800
+++ linux-2.6.1-ipv6mib7/include/linux/rtnetlink.h	2004-01-13 10:41:55.000000000 -0800
@@ -247,7 +247,7 @@
 {
 	__u32	rta_clntref;
 	__u32	rta_lastuse;
-	__s32	rta_expires;
+	__u32	rta_expires;	/* seconds */
 	__u32	rta_error;
 	__u32	rta_used;
 
diff -urN linux-2.6.1/net/ipv6/route.c linux-2.6.1-ipv6mib7/net/ipv6/route.c
--- linux-2.6.1/net/ipv6/route.c	2004-01-08 22:59:48.000000000 -0800
+++ linux-2.6.1-ipv6mib7/net/ipv6/route.c	2004-01-13 10:41:55.000000000 -0800
@@ -1535,8 +1535,8 @@
 		RTA_PUT(skb, RTA_OIF, sizeof(int), &rt->rt6i_dev->ifindex);
 	RTA_PUT(skb, RTA_PRIORITY, 4, &rt->rt6i_metric);
 	ci.rta_lastuse = jiffies_to_clock_t(jiffies - rt->u.dst.lastuse);
-	if (rt->rt6i_expires)
-		ci.rta_expires = jiffies_to_clock_t(rt->rt6i_expires - jiffies);
+	if (rt->rt6i_expires && time_after(rt->rt6i_expires, jiffies))
+		ci.rta_expires = (rt->rt6i_expires - jiffies)/HZ;
 	else
 		ci.rta_expires = 0;
 	ci.rta_used = rt->u.dst.__use;

--------------Boundary-00=_X09IDHM9YSKWUPJ5TXOR--
