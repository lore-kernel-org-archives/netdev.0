From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 07:47:00 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201204700.GA20349@gondor.apana.org.au>
References: <20031201201651.GA20194@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031201201651.GA20194@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 02, 2003 at 07:16:51AM +1100, herbert wrote:
> 
> I found out that PMTU only works on those routing cache entries where
> rt_src != 0.  This patch should make it work for all matching entries.

That patch removed one line too many.  This one should be better.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/net/ipv4/route.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/route.c,v
retrieving revision 1.3
diff -u -r1.3 route.c
--- kernel-source-2.5/net/ipv4/route.c	24 Nov 2003 09:52:04 -0000	1.3
+++ kernel-source-2.5/net/ipv4/route.c	1 Dec 2003 20:45:22 -0000
@@ -1260,8 +1260,9 @@
 			smp_read_barrier_depends();
 			if (rth->fl.fl4_dst == daddr &&
 			    rth->fl.fl4_src == skeys[i] &&
+			    (rth->fl.fl4_src == iph->saddr ||
+			     rth->rt_src == iph->saddr) &&
 			    rth->rt_dst  == daddr &&
-			    rth->rt_src  == iph->saddr &&
 			    rth->fl.fl4_tos == tos &&
 			    rth->fl.iif == 0 &&
 			    !(dst_metric_locked(&rth->u.dst, RTAX_MTU))) {

--YZ5djTAD1cGYuMQK--
