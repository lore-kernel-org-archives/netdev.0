From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [AH4] Save daddr iff options are present
Date: Sat, 24 Jul 2004 11:44:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724014415.GA5866@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="r5Pyd7+fXNt84Ff3"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is a little optimisation for AH4.  When I moved the tunnel code out,
I put the daddr copying code on the main path which is unnecessary since
daddr is only mutable if IP options are present.

This patch moves the saving and restoring of daddr under the check for
the existence of IP options.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ah4.c 1.37 vs edited =====
--- 1.37/net/ipv4/ah4.c	2004-07-12 20:00:21 +10:00
+++ edited/net/ipv4/ah4.c	2004-07-24 11:39:40 +10:00
@@ -73,9 +73,9 @@
 	iph->tos = top_iph->tos;
 	iph->ttl = top_iph->ttl;
 	iph->frag_off = top_iph->frag_off;
-	iph->daddr = top_iph->daddr;
 
 	if (top_iph->ihl != 5) {
+		iph->daddr = top_iph->daddr;
 		memcpy(iph+1, top_iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
 		err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
 		if (err)
@@ -104,9 +104,10 @@
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
 	top_iph->frag_off = iph->frag_off;
-	top_iph->daddr = iph->daddr;
-	if (top_iph->ihl != 5)
+	if (top_iph->ihl != 5) {
+		top_iph->daddr = iph->daddr;
 		memcpy(top_iph+1, iph+1, top_iph->ihl*4 - sizeof(struct iphdr));
+	}
 
 	ip_send_check(top_iph);
 

--r5Pyd7+fXNt84Ff3--
