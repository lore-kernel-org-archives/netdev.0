From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix ICMP tempsel
Date: Sun, 20 Feb 2005 09:35:14 +0100
Message-ID: <42184BC2.1030907@trash.net>
References: <4217266F.6090700@trash.net> <20050219184351.GB10773@gondor.apana.org.au> <42182082.9060301@trash.net> <20050220.155527.54695259.yoshfuji@linux-ipv6.org> <20050220073719.GA13008@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030203030103040308070504"
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050220073719.GA13008@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030203030103040308070504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> So here we can do something like this.  Please note that this patch
> needs to be used with Patrick's earlier work.  Patrick, if you're
> OK with it please merge it in with your patch.

Attached. Now I understand what Yoshifuji meant with byteorder :)

> 
> By all means give xfrm_selector_fixup a better name :)

I'm not very talented with choosing good names myself, so I kept it.

On second thought .. isn't there a risk of confusing userspace by
changing the masks ?

Regards
Patrick

--------------030203030103040308070504
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/20 09:29:12+01:00 kaber@coreworks.de 
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#      
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport,
#   kills xfrm_flowi_{sport,dport} and converts the selector values only once
#   when they enter the kernel.
#   
#   Mostly done by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/xfrm/xfrm_user.c
#   2005/02/20 09:29:04+01:00 kaber@coreworks.de +7 -1
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#      
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport,
#   kills xfrm_flowi_{sport,dport} and converts the selector values only once
#   when they enter the kernel.
#   
#   Mostly done by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/key/af_key.c
#   2005/02/20 09:29:04+01:00 kaber@coreworks.de +3 -0
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#      
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport,
#   kills xfrm_flowi_{sport,dport} and converts the selector values only once
#   when they enter the kernel.
#   
#   Mostly done by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/xfrm.h
#   2005/02/20 09:29:04+01:00 kaber@coreworks.de +15 -44
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#      
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport,
#   kills xfrm_flowi_{sport,dport} and converts the selector values only once
#   when they enter the kernel.
#   
#   Mostly done by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/flow.h
#   2005/02/20 09:29:04+01:00 kaber@coreworks.de +2 -0
#   [XFRM]: Fix ICMP tempsel
#   
#   The selector ports are initialized to fl_ip_sport/fl_ip_dport instead
#   of xfrm_flowi_sport(fl)/xfrm_flowi_dport(fl). This is wrong for ICMP,
#   type and code should be stored in sport and dport, in struct flowi both
#   are contained in fl_ip_sport.
#      
#   This patch adjusts struct flowi to store ICMP type/code in sport/dport,
#   kills xfrm_flowi_{sport,dport} and converts the selector values only once
#   when they enter the kernel.
#   
#   Mostly done by Herbert Xu <herbert@gondor.apana.org.au>
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/flow.h b/include/net/flow.h
--- a/include/net/flow.h	2005-02-20 09:30:04 +01:00
+++ b/include/net/flow.h	2005-02-20 09:30:04 +01:00
@@ -58,7 +58,9 @@
 		} ports;
 
 		struct {
+			__u8	pad1;
 			__u8	type;
+			__u8	pad2;
 			__u8	code;
 		} icmpt;
 
diff -Nru a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h	2005-02-20 09:30:04 +01:00
+++ b/include/net/xfrm.h	2005-02-20 09:30:04 +01:00
@@ -417,53 +417,13 @@
 	return 1;
 }
 
-static __inline__
-u16 xfrm_flowi_sport(struct flowi *fl)
-{
-	u16 port;
-	switch(fl->proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_SCTP:
-		port = fl->fl_ip_sport;
-		break;
-	case IPPROTO_ICMP:
-	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_type);
-		break;
-	default:
-		port = 0;	/*XXX*/
-	}
-	return port;
-}
-
-static __inline__
-u16 xfrm_flowi_dport(struct flowi *fl)
-{
-	u16 port;
-	switch(fl->proto) {
-	case IPPROTO_TCP:
-	case IPPROTO_UDP:
-	case IPPROTO_SCTP:
-		port = fl->fl_ip_dport;
-		break;
-	case IPPROTO_ICMP:
-	case IPPROTO_ICMPV6:
-		port = htons(fl->fl_icmp_code);
-		break;
-	default:
-		port = 0;	/*XXX*/
-	}
-	return port;
-}
-
 static inline int
 __xfrm4_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
 	return  addr_match(&fl->fl4_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl4_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((fl->fl_ip_dport ^ sel->dport) & sel->dport_mask) &&
+		!((fl->fl_ip_sport ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
@@ -473,8 +433,8 @@
 {
 	return  addr_match(&fl->fl6_dst, &sel->daddr, sel->prefixlen_d) &&
 		addr_match(&fl->fl6_src, &sel->saddr, sel->prefixlen_s) &&
-		!((xfrm_flowi_dport(fl) ^ sel->dport) & sel->dport_mask) &&
-		!((xfrm_flowi_sport(fl) ^ sel->sport) & sel->sport_mask) &&
+		!((fl->fl_ip_dport ^ sel->dport) & sel->dport_mask) &&
+		!((fl->fl_ip_sport ^ sel->sport) & sel->sport_mask) &&
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
@@ -490,6 +450,17 @@
 		return __xfrm6_selector_match(sel, fl);
 	}
 	return 0;
+}
+
+static inline void xfrm_selector_fixup(struct xfrm_selector *sel)
+{
+	switch (sel->proto) {
+	case IPPROTO_ICMP:
+	case IPPROTO_ICMPV6:
+		sel->sport_mask &= htons(0xff);
+		sel->dport_mask &= htons(0xff);
+		break;
+	}
 }
 
 /* A struct encoding bundle of transformations to apply to some set of flow.
diff -Nru a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c	2005-02-20 09:30:04 +01:00
+++ b/net/key/af_key.c	2005-02-20 09:30:04 +01:00
@@ -1909,6 +1909,8 @@
 	if (xp->selector.dport)
 		xp->selector.dport_mask = ~0;
 
+	xfrm_selector_fixup(&xp->selector);
+
 	xp->lft.soft_byte_limit = XFRM_INF;
 	xp->lft.hard_byte_limit = XFRM_INF;
 	xp->lft.soft_packet_limit = XFRM_INF;
@@ -1999,6 +2001,7 @@
 	if (sel.dport)
 		sel.dport_mask = ~0;
 
+	xfrm_selector_fixup(&sel);
 	xp = xfrm_policy_bysel(pol->sadb_x_policy_dir-1, &sel, 1);
 	if (xp == NULL)
 		return -ENOENT;
diff -Nru a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c	2005-02-20 09:30:04 +01:00
+++ b/net/xfrm/xfrm_user.c	2005-02-20 09:30:04 +01:00
@@ -204,6 +204,7 @@
 {
 	memcpy(&x->id, &p->id, sizeof(x->id));
 	memcpy(&x->sel, &p->sel, sizeof(x->sel));
+	xfrm_selector_fixup(&x->sel);
 	memcpy(&x->lft, &p->lft, sizeof(x->lft));
 	x->props.mode = p->mode;
 	x->props.replay_window = p->replay_window;
@@ -626,6 +627,7 @@
 	xp->priority = p->priority;
 	xp->index = p->index;
 	memcpy(&xp->selector, &p->sel, sizeof(xp->selector));
+	xfrm_selector_fixup(&xp->selector);
 	memcpy(&xp->lft, &p->lft, sizeof(xp->lft));
 	xp->action = p->action;
 	xp->flags = p->flags;
@@ -808,6 +810,7 @@
 	struct xfrm_userpolicy_id *p;
 	int err;
 	int delete;
+	struct xfrm_selector sel;
 
 	p = NLMSG_DATA(nlh);
 	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
@@ -818,8 +821,11 @@
 
 	if (p->index)
 		xp = xfrm_policy_byid(p->dir, p->index, delete);
-	else
+	else {
+		memcpy(&sel, &p->sel, sizeof(sel));
+		xfrm_selector_fixup(&sel);
 		xp = xfrm_policy_bysel(p->dir, &p->sel, delete);
+	}
 	if (xp == NULL)
 		return -ENOENT;
 

--------------030203030103040308070504--
