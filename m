From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] [IPV6] Use dev_get_flags() while building inet6 ifinfo message
Date: Tue, 15 Mar 2005 01:14:17 +0100
Message-ID: <20050315001417.GB3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use dev_get_flags() in inet6_fill_ifinfo() to fetch interface flags
to ensure correctly reporting IFF_PROMISC and IFF_ALLMULTI flags.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-bk10.orig/net/ipv6/addrconf.c	2005-03-14 19:40:28.000000000 +0100
+++ linux-2.6.11-bk10/net/ipv6/addrconf.c	2005-03-14 21:08:28.000000000 +0100
@@ -2923,12 +2923,8 @@
 	r->ifi_family = AF_INET6;
 	r->ifi_type = dev->type;
 	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev->flags;
+	r->ifi_flags = dev_get_flags(dev);
 	r->ifi_change = 0;
-	if (!netif_running(dev) || !netif_carrier_ok(dev))
-		r->ifi_flags &= ~IFF_RUNNING;
-	else
-		r->ifi_flags |= IFF_RUNNING;
 
 	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
 
