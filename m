From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: linux-next: Tree for March 27 (netfilter build error)
Date: Sun, 29 Mar 2009 10:47:04 +0400
Message-ID: <20090329064704.GA7255@localhost>
References: <20090327231924.4e4168c5.sfr@canb.auug.org.au> <49CD0368.2010805@oracle.com> <20090327.160107.184169637.davem@davemloft.net> <20090328102852.GA7697@localhost> <49CEF882.5000005@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, davem@davemloft.net,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49CEF882.5000005@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Randy Dunlap - Sat, Mar 28, 2009 at 09:26:42PM -0700]
... 
| works_for_me.  Thanks.
| but missing S-O-B.
| 
| Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
...

Thanks for testing Randy. So if nobody will complain
here is a solid version of the patch. Though I would like
if Pablo or Patrick confirm its correctness. Thanks!

       Cyrill
---
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: netfilter: xtables - build issue fix

Randy Dunlap reported:
| with CONFIG_IPV6=n:
|
| ERROR: "__ipv6_addr_type" [net/netfilter/xt_cluster.ko] undefined!

ipv6_addr_type does depend on IPv6 being tuned on.
Guard it with CONFIG_IPV6/_MODULE.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/netfilter/xt_cluster.c |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.git/net/netfilter/xt_cluster.c
===================================================================
--- linux-2.6.git.orig/net/netfilter/xt_cluster.c
+++ linux-2.6.git/net/netfilter/xt_cluster.c
@@ -67,8 +67,10 @@ xt_cluster_is_multicast_addr(const struc
 		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
 		break;
 	case NFPROTO_IPV6:
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		is_multicast = ipv6_addr_type(&ipv6_hdr(skb)->daddr) &
 						IPV6_ADDR_MULTICAST;
+#endif
 		break;
 	default:
 		WARN_ON(1);
