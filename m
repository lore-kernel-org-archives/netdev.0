From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [12/*] [IPSEC] Handle local_df in IPv4
Date: Mon, 14 Mar 2005 21:26:14 +1100
Message-ID: <20050314102614.GA9610@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5vNYLRcllDrimb99"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050308102741.GA23468@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

When cleaning up the remaining users of dst_pmtu I noticed that
local_df wasn't being treated correctly in IPsec.  In fact, if
you socket's dst went over IPsec, local_df is essentailly ignored.

This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I was going to do the same thing to IPv6.  Unfortunately it seems
that we don't have any local_df support over there.  That is, we
always fragment outbound UDP/raw packets.  Did I miss something?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-12

===== net/ipv4/xfrm4_output.c 1.7 vs edited =====
--- 1.7/net/ipv4/xfrm4_output.c	2005-03-07 16:33:59 +11:00
+++ edited/net/ipv4/xfrm4_output.c	2005-03-14 13:55:35 +11:00
@@ -78,7 +78,7 @@
 
 	IPCB(skb)->flags |= IPSKB_XFRM_TUNNEL_SIZE;
 	
-	if (!(iph->frag_off & htons(IP_DF)))
+	if (!(iph->frag_off & htons(IP_DF)) || skb->local_df)
 		goto out;
 
 	dst = skb->dst;

--5vNYLRcllDrimb99--
