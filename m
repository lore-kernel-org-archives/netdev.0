From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH net] tcp: fastopen: avoid negative sk_forward_alloc
Date: Wed, 7 Sep 2016 14:48:06 -0500
Message-ID: <57D06EF6.7090507@akamai.com>
References: <1473262451.10725.43.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([23.79.238.175]:42830 "EHLO
        prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755461AbcIGTzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 15:55:02 -0400
In-Reply-To: <1473262451.10725.43.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2016 10:34 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When DATA and/or FIN are carried in a SYN/ACK message or SYN message,
> we append an skb in socket receive queue, but we forget to call
> sk_forced_mem_schedule().
>
> Effect is that the socket has a negative sk->sk_forward_alloc as long as
> the message is not read by the application.
>
> Josh Hunt fixed a similar issue in commit d22e15371811 ("tcp: fix tcp
> fin memory accounting")
>
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   net/ipv4/tcp_fastopen.c |    1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
> index 62a5751d4fe1..4e777a3243f9 100644
> --- a/net/ipv4/tcp_fastopen.c
> +++ b/net/ipv4/tcp_fastopen.c
> @@ -150,6 +150,7 @@ void tcp_fastopen_add_skb(struct sock *sk, struct sk_buff *skb)
>   	tp->segs_in = 0;
>   	tcp_segs_in(tp, skb);
>   	__skb_pull(skb, tcp_hdrlen(skb));
> +	sk_forced_mem_schedule(sk, skb->truesize);
>   	skb_set_owner_r(skb, sk);
>
>   	TCP_SKB_CB(skb)->seq++;
>
>

The change makes sense to me. Thanks Eric!

Reviewed-by: Josh Hunt <johunt@akamai.com>
