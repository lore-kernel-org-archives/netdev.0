From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sat, 18 Sep 2004 18:06:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918180647.6be57884.davem@davemloft.net>
References: <20040917230803.GJ2678@sunbeam.de.gnumonks.org>
	<20040918.084304.75142669.yoshfuji@linux-ipv6.org>
	<20040918220211.GI6005@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040918220211.GI6005@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 19 Sep 2004 00:02:11 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> Now I'm stuck with another issue:  The interfaces suddenly no logner
> get any link-local addresses:

Probably due to this change.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/10 14:50:26-07:00 yoshfuji@linux-ipv6.org 
#   [IPV6]: Deprecate all-on-link assumption
#   
#   If we don't have IPv6 default routes, we assume all ipv6 destinations 
#   are on-link as specified in RFC2461. It, however, is considered harmful now;
#   it is problematic with IPv6-capable nodes that do not have off-link
#   IPv6 connectivity (eg no default routers) and such nodes will take
#   a few seconds until they fall back to use IPv4.
#   
#   See <draft-ietf-v6ops-onlinkassumption-02.txt> for details.
#   
#   From: KUNITAKE Koichi <kunitake@anchor.jp>
#   Signed-off-by: KUNITAKE Koichi <kunitake@anchor.jp>
#   Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv6/addrconf.c
#   2004/09/10 14:50:09-07:00 yoshfuji@linux-ipv6.org +4 -12
#   [IPV6]: Deprecate all-on-link assumption
#   
#   If we don't have IPv6 default routes, we assume all ipv6 destinations 
#   are on-link as specified in RFC2461. It, however, is considered harmful now;
#   it is problematic with IPv6-capable nodes that do not have off-link
#   IPv6 connectivity (eg no default routers) and such nodes will take
#   a few seconds until they fall back to use IPv4.
#   
#   See <draft-ietf-v6ops-onlinkassumption-02.txt> for details.
#   
#   From: KUNITAKE Koichi <kunitake@anchor.jp>
#   Signed-off-by: KUNITAKE Koichi <kunitake@anchor.jp>
#   Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-09-18 17:50:32 -07:00
+++ b/net/ipv6/addrconf.c	2004-09-18 17:50:32 -07:00
@@ -2108,21 +2108,13 @@
 
 		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
 	} else {
-		struct in6_rtmsg rtmsg;
-
 		spin_unlock(&ifp->lock);
-
+		/*
+		 * Note: we do not support deprecated "all on-link"
+		 * assumption any longer.
+		 */
 		printk(KERN_DEBUG "%s: no IPv6 routers present\n",
 		       ifp->idev->dev->name);
-
-		memset(&rtmsg, 0, sizeof(struct in6_rtmsg));
-		rtmsg.rtmsg_type = RTMSG_NEWROUTE;
-		rtmsg.rtmsg_metric = IP6_RT_PRIO_ADDRCONF;
-		rtmsg.rtmsg_flags = (RTF_ALLONLINK | RTF_DEFAULT | RTF_UP);
-
-		rtmsg.rtmsg_ifindex = ifp->idev->dev->ifindex;
-
-		ip6_route_add(&rtmsg, NULL, NULL);
 	}
 
 out:
