From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc1-mm5: TCP oopses
Date: Mon, 13 Sep 2004 21:55:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913215556.73026adf.davem@davemloft.net>
References: <20040913190858.12544431.davem@davemloft.net>
	<E1C745E-00024r-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C745E-00024r-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


James, does this make your problem go away?

Thanks for testing.

===== net/ipv4/tcp_output.c 1.57 vs edited =====
--- 1.57/net/ipv4/tcp_output.c	2004-09-12 16:17:23 -07:00
+++ edited/net/ipv4/tcp_output.c	2004-09-13 21:36:59 -07:00
@@ -991,7 +991,7 @@
 		/* New SKB created, account for it. */
 		new_factor = TCP_SKB_CB(skb)->tso_factor;
 		tcp_dec_pcount_explicit(&tp->packets_out,
-					new_factor - old_factor);
+					old_factor - new_factor);
 		tcp_inc_pcount(&tp->packets_out, skb->next);
 	}
 
