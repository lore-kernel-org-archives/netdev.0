From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPv6][IPsec] stop infinite loop
Date: Sat, 30 Apr 2005 11:25:25 +0900
Message-ID: <4272EC95.20401@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

IPv6 IPsec tunnel mode of linux-2.6.12-rc3 does not work
on my PCs. It seems to be infinitely looped.

I think dst_check causes it because it exptects the obsolete
of normal dst (I mean not xfrm) is 0 but ip6_route_add sets it -1.
This patch changes the default value of the obsolete.
This patch is for linux-2.6.12-rc3.

I will not be able to response quickly because I'm in holidays :-)

Signed-off-by Kazunori Miyazawa <kazunori@miyazawa.org>

diff -ruN a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	2005-04-30 10:27:49.000000000 +0900
+++ b/net/ipv6/route.c	2005-04-30 10:34:04.000000000 +0900
@@ -113,7 +113,7 @@
 			.__refcnt	= ATOMIC_INIT(1),
 			.__use		= 1,
 			.dev		= &loopback_dev,
-			.obsolete	= -1,
+			.obsolete	= 0,
 			.error		= -ENETUNREACH,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
 			.input		= ip6_pkt_discard,
@@ -825,7 +825,7 @@
 		goto out;
 	}

-	rt->u.dst.obsolete = -1;
+	rt->u.dst.obsolete = 0;
 	rt->rt6i_expires = clock_t_to_jiffies(rtmsg->rtmsg_info);
 	if (nlh && (r = NLMSG_DATA(nlh))) {
 		rt->rt6i_protocol = r->rtm_protocol;
@@ -1407,7 +1407,7 @@
 	rt->u.dst.metrics[RTAX_MTU-1] = ipv6_get_mtu(rt->rt6i_dev);
 	rt->u.dst.metrics[RTAX_ADVMSS-1] = ipv6_advmss(dst_mtu(&rt->u.dst));
 	rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
-	rt->u.dst.obsolete = -1;
+	rt->u.dst.obsolete = 0;

 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
 	if (!anycast)
