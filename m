From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] [IPV6] NDISC: ensure responding to NS without link-layer
 information.
Date: Thu, 16 Sep 2004 12:59:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916.125921.56481183.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

When sending NA in response to NS, we may not know the 
link-layer address for the destination of the NA 
since unicast NS is not required to include its link-layer information.
In this case, we first need to resolve the link-layer address.
(RFC 2461 7.2.4)

We now create neighbour entry for the destination 
and link-layer information will be automatically solved 
in the output path.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Also available at <bk://bk.skbuff.net:20609/linux-2.6-ndp-20040916/>.

Thanks.

diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	2004-09-16 12:54:26 +09:00
+++ b/net/ipv6/ndisc.c	2004-09-16 12:54:26 +09:00
@@ -810,7 +810,8 @@
 	 *	update / create cache entry
 	 *	for the source address
 	 */
-	neigh = __neigh_lookup(&nd_tbl, saddr, dev, lladdr || !dev->addr_len);
+	neigh = __neigh_lookup(&nd_tbl, saddr, dev,
+			       !inc || lladdr || !dev->addr_len);
 	if (neigh)
 		neigh_update(neigh, lladdr, NUD_STALE, 
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
