From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 27 Sep 2004 11:27:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBkIW-0001dF-00@gondolin.me.apana.org.au>
References: <20040923164149.5368d291.davem@davemloft.net>
Cc: herbert@gondor.apana.org.au, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040923164149.5368d291.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> Previously we counted TSO frames as single "packets" as long as
> we could fit one more frame into the congestion window we'd spit
> out the whole TSO frame, and this kept the pipe full.

Indeed, I think the new code means that Minshall's check will disable
Nagle which is what was keeping TSO working properly.

Anton, could you please try this patch which disables Minshall's check
and see what it does?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== include/net/tcp.h 1.88 vs edited =====
--- 1.88/include/net/tcp.h	2004-09-15 06:57:07 +10:00
+++ edited/include/net/tcp.h	2004-09-27 11:25:56 +10:00
@@ -1461,8 +1461,7 @@
 		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 		((nonagle&TCP_NAGLE_CORK) ||
 		 (!nonagle &&
-		  tcp_get_pcount(&tp->packets_out) &&
-		  tcp_minshall_check(tp))));
+		  tcp_get_pcount(&tp->packets_out))));
 }
 
 extern void tcp_set_skb_tso_factor(struct sk_buff *, unsigned int);
