From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [14/*] [IPV6] Reload skb->dst after xfrm6_route_forward
Date: Mon, 14 Mar 2005 22:10:02 +1100
Message-ID: <20050314111002.GA29156@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fdj2RfSjLxBAspz7"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050314105313.GA21001@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

While replacing dst_pmtu in ip6_output I found this little gem.  In
ip6_forward we're not reloading the dst pointer after calling
xfrm6_route_forward.  So all subsequent dereferences of dst will
refer to its pre-IPsec value.

The solution is of course to refresh its value.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--fdj2RfSjLxBAspz7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-14

===== net/ipv6/ip6_output.c 1.85 vs edited =====
--- 1.85/net/ipv6/ip6_output.c	2005-03-03 16:12:38 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-03-14 22:05:31 +11:00
@@ -397,6 +397,7 @@
 		IP6_INC_STATS(IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
+	dst = skb->dst;
 
 	/* IPv6 specs say nothing about it, but it is clear that we cannot
 	   send redirects to source routed frames.

--fdj2RfSjLxBAspz7--
