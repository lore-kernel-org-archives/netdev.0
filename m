From: "David S. Miller" <davem@davemloft.net>
Subject: Re: oops when bringing up loopback device
Date: Mon, 28 Mar 2005 16:12:58 -0800
Message-ID: <20050328161258.7fbe28dd.davem@davemloft.net>
References: <20050328160248.595615a1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050328160248.595615a1@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Mar 2005 16:02:48 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> I am seeing this on one of my boxes with current net-2.6 tree.

You're missing the fix to net/ipv4/ip_mp_alg.h for some reason,
it is upstream for two days now and I added it to my tree the
weekend you left for spring break.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/19 16:45:16-08:00 davem@sunset.davemloft.net 
#   [IPV4]: Check multipath ops func pointers against NULL.
#   
#   Multipath algorithms are not required to implement
#   all of the methods.  Just the ones they need.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# include/net/ip_mp_alg.h
#   2005/03/19 16:44:15-08:00 davem@sunset.davemloft.net +6 -4
#   [IPV4]: Check multipath ops func pointers against NULL.
# 
diff -Nru a/include/net/ip_mp_alg.h b/include/net/ip_mp_alg.h
--- a/include/net/ip_mp_alg.h	2005-03-28 16:21:56 -08:00
+++ b/include/net/ip_mp_alg.h	2005-03-28 16:21:56 -08:00
@@ -36,7 +36,8 @@
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	struct ip_mp_alg_ops *ops = ip_mp_alg_table[rth->rt_multipath_alg];
 
-	if (ops && (rth->u.dst.flags & DST_BALANCED)) {
+	if (ops && ops->mp_alg_select_route &&
+	    (rth->u.dst.flags & DST_BALANCED)) {
 		ops->mp_alg_select_route(flp, rth, rp);
 		return 1;
 	}
@@ -52,7 +53,7 @@
 	for (i = IP_MP_ALG_NONE; i <= IP_MP_ALG_MAX; i++) {
 		struct ip_mp_alg_ops *ops = ip_mp_alg_table[i];
 
-		if (ops)
+		if (ops && ops->mp_alg_flush)
 			ops->mp_alg_flush();
 	}
 #endif
@@ -66,7 +67,7 @@
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	struct ip_mp_alg_ops *ops = ip_mp_alg_table[rth->rt_multipath_alg];
 
-	if (ops)
+	if (ops && ops->mp_alg_set_nhinfo)
 		ops->mp_alg_set_nhinfo(network, netmask, prefixlen, nh);
 #endif
 }
@@ -76,7 +77,8 @@
 #ifdef CONFIG_IP_ROUTE_MULTIPATH_CACHED
 	struct ip_mp_alg_ops *ops = ip_mp_alg_table[rth->rt_multipath_alg];
 
-	if (ops && (rth->u.dst.flags & DST_BALANCED))
+	if (ops && ops->mp_alg_remove &&
+	    (rth->u.dst.flags & DST_BALANCED))
 		ops->mp_alg_remove(rth);
 #endif
 }
