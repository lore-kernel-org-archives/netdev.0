From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix UDP filter condition when do checksum
Date: Mon, 31 Jul 2006 21:36:07 +1000
Message-ID: <E1G7W47-0006ss-00@gondolin.me.apana.org.au>
References: <1154342022.3959.10.camel@LINE>
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60177 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932272AbWGaLgK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 07:36:10 -0400
To: yjwei@nanjing-fnst.com (Wei Yongjun)
In-Reply-To: <1154342022.3959.10.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
> In udp_queue_rcv_skb(), checksum condition is error. When UDP filter is
> set, checksum is be done, but if UDP filter is not set, checksum will
> not be done. So I think this is a BUG. Following is my patch:
> 
> --- a/net/ipv4/udp.c    2006-07-31 09:33:45.392479344 -0400
> +++ b/net/ipv4/udp.c    2006-07-31 17:10:41.271632200 -0400
> @@ -1018,7 +1018,7 @@ static int udp_queue_rcv_skb(struct sock
>                /* FALLTHROUGH -- it's a UDP Packet */
>        }
> 
> -       if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
> +       if (!sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
>                if (__udp_checksum_complete(skb)) {
>                        UDP_INC_STATS_BH(UDP_MIB_INERRORS);
>                        kfree_skb(skb);

For the record, this isn't correct since the only reason we're computing
a checksum here rather than recv(2) time is if we have a filter attached.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
