From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 17:10:09 +0800
Message-ID: <20081016091009.GA5794@gondor.apana.org.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016050810.GA8240@samad.com.au> <20081016064142.GA5064@gondor.apana.org.au> <20081016070934.GA10150@samad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alex Samad <alex@samad.com.au>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081016070934.GA10150@samad.com.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2008 at 06:09:34PM +1100, Alex Samad wrote:
>
> just about, within a 5-10 min window

Great.  Please apply this patch and let me know what it prints
out (if anything).

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 16d43f2..72af09d 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -233,6 +233,13 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 
+	if (WARN_ON(skb_is_gso(skb) && skb->ip_summed != CHECKSUM_PARTIAL)) {
+		printk("%s: %d %d %d 0x%x 0x%x 0x%lx", skb->dst->dev->name,
+		       skb->ip_summed, skb_shinfo(skb)->gso_size, skb->len,
+		       skb_shinfo(skb)->gso_type, sk->sk_route_caps,
+		       skb->dst->dev->features);
+	}
+
 	return ip6_xmit(sk, skb, &fl, np->opt, 0);
 }
 
