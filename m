From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4] Clear DF bit in ip_fragment fast path
Date: Mon, 21 Mar 2005 22:16:37 +1100
Message-ID: <20050321111637.GA24617@gondor.apana.org.au>
References: <20050321105622.GA23809@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FCuugMFkClbJLl1L"
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050321105622.GA23809@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

It is possible for ip_fragment() to send out head fragments with
both DF and MF set for packets with local_df set to true.  This is
because the fast path tries to only modify the MF bit of the head
fragment.

Since the offset is always zero for the head fragment, and we know
that DF should be cleared in case of local_df, we can change |= to
a straight assignment.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--FCuugMFkClbJLl1L
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ip_output.c 1.80 vs edited =====
--- 1.80/net/ipv4/ip_output.c	2005-03-19 05:43:26 +11:00
+++ edited/net/ipv4/ip_output.c	2005-03-21 22:09:45 +11:00
@@ -498,7 +498,7 @@
 		skb->data_len = first_len - skb_headlen(skb);
 		skb->len = first_len;
 		iph->tot_len = htons(first_len);
-		iph->frag_off |= htons(IP_MF);
+		iph->frag_off = htons(IP_MF);
 		ip_send_check(iph);
 
 		for (;;) {

--FCuugMFkClbJLl1L--
