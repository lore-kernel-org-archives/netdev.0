From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Also fix tunnel skb->h.raw bug in ip6_tunnel.c
Date: Wed, 5 Nov 2003 13:02:02 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0311051253420.27592@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

I noticed the skb->h.raw bug was fixed for ipip.c, ip_gre.c and sit.c, but
not for ip6_tunnel.c. Here is a patch for it as well. Please apply!

Thanks,
Ville

===== net/ipv6/ip6_tunnel.c 1.12 vs edited =====
--- 1.12/net/ipv6/ip6_tunnel.c	Sun Oct 19 10:12:04 2003
+++ edited/net/ipv6/ip6_tunnel.c	Wed Nov  5 09:48:13 2003
@@ -681,7 +681,6 @@
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
 		goto tx_err_dst_release;
 	}
-	skb->h.raw = skb->nh.raw;

 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
@@ -702,6 +701,8 @@
 	}
 	dst_release(skb->dst);
 	skb->dst = dst_clone(dst);
+
+	skb->h.raw = skb->nh.raw;

 	if (opt)
 		ipv6_push_nfrag_opts(skb, opt, &proto, NULL);
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
