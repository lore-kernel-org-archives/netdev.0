From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NATT] Fix uh->len with IP options
Date: Fri, 9 Jul 2004 21:48:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709114802.GA13344@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I just noticed that the UDP header length in esp4_output() is incorrect
when IP options are present (in transport mode).  This patch fixes exactly
that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/esp4.c 1.50 vs edited =====
--- 1.50/net/ipv4/esp4.c	2004-07-09 20:19:08 +10:00
+++ edited/net/ipv4/esp4.c	2004-07-09 21:45:46 +10:00
@@ -124,7 +124,7 @@
 		uh = (struct udphdr *)esph;
 		uh->source = encap->encap_sport;
 		uh->dest = encap->encap_dport;
-		uh->len = htons((*pskb)->len + alen - sizeof(struct iphdr));
+		uh->len = htons((*pskb)->len + alen - iph->ihl*4);
 		uh->check = 0;
 
 		switch (encap->encap_type) {

--k1lZvvs/B4yU6o8G--
