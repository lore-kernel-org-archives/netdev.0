From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: Flowinfo fix in ip6_tunnel.c
Date: Wed, 5 Nov 2003 13:35:33 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0311051302140.27592@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

would you also apply this minor patch? This makes the handling of
flowlabels consistent with the way flowlabels are passed from userspace
using sockopts.

Thanks,
Ville


===== net/ipv6/ip6_tunnel.c 1.13 vs edited =====
--- 1.13/net/ipv6/ip6_tunnel.c	Wed Nov  5 09:52:58 2003
+++ edited/net/ipv6/ip6_tunnel.c	Wed Nov  5 10:01:12 2003
@@ -810,9 +810,9 @@
 	fl->fl6_flowlabel = 0;

 	if (!(p->flags&IP6_TNL_F_USE_ORIG_TCLASS))
-		fl->fl6_flowlabel |= IPV6_TCLASS_MASK & htonl(p->flowinfo);
+		fl->fl6_flowlabel |= IPV6_TCLASS_MASK & p->flowinfo;
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_FLOWLABEL))
-		fl->fl6_flowlabel |= IPV6_FLOWLABEL_MASK & htonl(p->flowinfo);
+		fl->fl6_flowlabel |= IPV6_FLOWLABEL_MASK & p->flowinfo;

 	ip6_tnl_set_cap(t);

--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
