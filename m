From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [21/*] [IPv4] Fix MTU check in ipmr_queue_xmit
Date: Fri, 18 Mar 2005 20:03:10 +1100
Message-ID: <20050318090310.GA28443@gondor.apana.org.au>
References: <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050315095837.GA7130@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Somehow I missed four files with dst_pmtu usages in them.  I'm going
to split them along the sames lines I did before: bug fixes and then
the trivial changes.

Here is a patch that replaces dst_pmtu with dst_pmtu in ipmr.c
since this is straight IPIP tunneling equivalent to what we have
in ipip.c.

As it is we may send ICMP packets when IPsec is present which is
exactly what the comment says that we shouldn't do.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
  
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-21

===== net/ipv4/ipmr.c 1.46 vs edited =====
--- 1.46/net/ipv4/ipmr.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv4/ipmr.c	2005-03-18 19:56:33 +11:00
@@ -1171,7 +1171,7 @@
 
 	dev = rt->u.dst.dev;
 
-	if (skb->len+encap > dst_pmtu(&rt->u.dst) && (ntohs(iph->frag_off) & IP_DF)) {
+	if (skb->len+encap > dst_mtu(&rt->u.dst) && (ntohs(iph->frag_off) & IP_DF)) {
 		/* Do not fragment multicasts. Alas, IPv4 does not
 		   allow to send ICMP, so that packets will disappear
 		   to blackhole.

--Qxx1br4bt0+wmkIi--
