From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Always set hoplimit
Date: Thu, 13 Nov 2003 22:04:38 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113110438.GA29522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Is there any reason why local/broadcast packets should have a ttl of zero?
This is the result of the HOPLIMIT change as those packets doesn't get
their HOPLIMIT set.  This patch sets it for them.

Am I missing something?
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.4/net/ipv4/route.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.4/net/ipv4/route.c,v
retrieving revision 1.6
diff -u -r1.6 route.c
--- kernel-source-2.4/net/ipv4/route.c	3 Sep 2003 10:27:21 -0000	1.6
+++ kernel-source-2.4/net/ipv4/route.c	13 Nov 2003 10:58:04 -0000
@@ -1275,9 +1275,6 @@
 			rt->rt_gateway = FIB_RES_GW(*res);
 		memcpy(rt->u.dst.metrics, fi->fib_metrics,
 		       sizeof(rt->u.dst.metrics));
-		if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
-			rt->u.dst.metrics[RTAX_HOPLIMIT-1] =
-				sysctl_ip_default_ttl;
 		if (fi->fib_mtu == 0) {
 			rt->u.dst.metrics[RTAX_MTU-1] = rt->u.dst.dev->mtu;
 			if (rt->u.dst.metrics[RTAX_LOCK-1] & (1 << RTAX_MTU) &&
@@ -1291,6 +1288,8 @@
 	} else
 		rt->u.dst.metrics[RTAX_MTU-1]= rt->u.dst.dev->mtu;
 
+	if (rt->u.dst.metrics[RTAX_HOPLIMIT-1] == 0)
+		rt->u.dst.metrics[RTAX_HOPLIMIT-1] = sysctl_ip_default_ttl;
 	if (rt->u.dst.metrics[RTAX_MTU-1] > IP_MAX_MTU)
 		rt->u.dst.metrics[RTAX_MTU-1] = IP_MAX_MTU;
 	if (rt->u.dst.metrics[RTAX_ADVMSS-1] == 0)

--RnlQjJ0d97Da+TV1--
