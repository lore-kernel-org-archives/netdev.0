From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Send TCP reset through dst_output in ipt_REJECT
Date: Thu, 17 Mar 2005 21:51:45 +1100
Message-ID: <20050317105145.GA20089@gondor.apana.org.au>
References: <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050315100522.GA7275@gondor.apana.org.au> <20050315102450.0f3f1618.davem@davemloft.net> <42373142.6090902@trash.net> <20050315204006.GB22349@gondor.apana.org.au> <42374A35.6020308@trash.net> <20050316105100.GA8404@gondor.apana.org.au> <42388263.3090602@trash.net> <20050316144424.689d5981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Cc: Patrick McHardy <kaber@trash.net>, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050316144424.689d5981.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I noticed that the TCP reset code in ipt_REJECT didn't call dst_output
either so it also bypasses IPsec processing.  Here is a patch to fix
that and use the correct MTU value.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-20

===== net/ipv4/netfilter/ipt_REJECT.c 1.36 vs edited =====
--- 1.36/net/ipv4/netfilter/ipt_REJECT.c	2005-03-17 09:44:14 +11:00
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	2005-03-17 14:18:20 +11:00
@@ -207,13 +207,13 @@
 					   nskb->nh.iph->ihl);
 
 	/* "Never happens" */
-	if (nskb->len > dst_pmtu(nskb->dst))
+	if (nskb->len > dst_mtu(nskb->dst))
 		goto free_nskb;
 
 	nf_ct_attach(nskb, oldskb);
 
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		ip_finish_output);
+		dst_output);
 	return;
 
  free_nskb:

--VS++wcV0S1rZb1Fb--
