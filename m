From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 07:16:51 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201201651.GA20194@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Nq2Wo0NMKNjxTN9z"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I found out that PMTU only works on those routing cache entries where
rt_src != 0.  This patch should make it work for all matching entries.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Nq2Wo0NMKNjxTN9z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/net/ipv4/route.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/route.c,v
retrieving revision 1.3
diff -u -r1.3 route.c
--- kernel-source-2.5/net/ipv4/route.c	24 Nov 2003 09:52:04 -0000	1.3
+++ kernel-source-2.5/net/ipv4/route.c	1 Dec 2003 20:15:40 -0000
@@ -1259,9 +1259,9 @@
 		     rth = rth->u.rt_next) {
 			smp_read_barrier_depends();
 			if (rth->fl.fl4_dst == daddr &&
-			    rth->fl.fl4_src == skeys[i] &&
+			    (rth->fl.fl4_src == iph->saddr ||
+			     rth->rt_src == iph->saddr) &&
 			    rth->rt_dst  == daddr &&
-			    rth->rt_src  == iph->saddr &&
 			    rth->fl.fl4_tos == tos &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {

--Nq2Wo0NMKNjxTN9z--
