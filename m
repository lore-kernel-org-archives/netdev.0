From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [13/*] [IPV4] Fix room calculation in icmp_send
Date: Mon, 14 Mar 2005 21:53:13 +1100
Message-ID: <20050314105313.GA21001@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+QahgC5+KEYLbs62"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050314102614.GA9610@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I'm now cleaning up all users of dst_pmtu with the aim of replacing
dst_pmtu with dst_mtu.  I'm going to start with the ones that actually
fix bugs.

This patch fixes the length calculation in icmp_send.  As it is
we're overestimating the space available by including the space
that would be used up by IPsec encapsulation.

IPv6 doesn't have this problem since its calculation is based
on 1280 instead of the PMTU.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-13

===== net/ipv4/icmp.c 1.49 vs edited =====
--- 1.49/net/ipv4/icmp.c	2004-12-28 16:30:43 +11:00
+++ edited/net/ipv4/icmp.c	2005-03-14 21:34:20 +11:00
@@ -560,7 +560,7 @@
 
 	/* RFC says return as much as we can without exceeding 576 bytes. */
 
-	room = dst_pmtu(&rt->u.dst);
+	room = dst_mtu(&rt->u.dst);
 	if (room > 576)
 		room = 576;
 	room -= sizeof(struct iphdr) + icmp_param.replyopts.optlen;

--+QahgC5+KEYLbs62--
