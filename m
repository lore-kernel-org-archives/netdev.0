From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Thu, 13 Jan 2005 17:50:17 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0501131741430.25252@w-sridhar.beaverton.ibm.com>
References: <20050113171234.3fde0925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: anton@samba.org, netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050113171234.3fde0925.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

I think with this patch we will start seeing
sk_wmem_queued assertions.

Currently sk_wmem_queued seems to be accounted
correctly, but this patch changes this value too.

-Sridhar

On Thu, 13 Jan 2005, David S. Miller wrote:

>
> Anton, can you and the other IBM folks who can reproduce
> the problem give this test patch a whirl?
>
> Herbert and I aren't exactly sure what the exact sequence
> of events is that causes the problem, but we do know that
> this code is highly suspect.
>
> [ BTW, Herbert, it just occurred to me that these adjustments
>   are incorrect for the skb->data pulling case since we really
>   aren't liberating the data. ]
>
> Thanks.
>
> ===== net/ipv4/tcp_output.c 1.75 vs edited =====
> --- 1.75/net/ipv4/tcp_output.c	2004-12-28 10:22:40 -08:00
> +++ edited/net/ipv4/tcp_output.c	2005-01-13 16:45:26 -08:00
> @@ -580,12 +580,12 @@
>
>  	TCP_SKB_CB(skb)->seq += len;
>  	skb->ip_summed = CHECKSUM_HW;
> -
> +#if 0
>  	skb->truesize	     -= len;
>  	sk->sk_queue_shrunk   = 1;
>  	sk->sk_wmem_queued   -= len;
>  	sk->sk_forward_alloc += len;
> -
> +#endif
>  	/* Any change of skb->len requires recalculation of tso
>  	 * factor and mss.
>  	 */
>
>
