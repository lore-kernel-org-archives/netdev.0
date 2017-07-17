From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: initialize treq->txhash in cookie_v6_check()
Date: Mon, 17 Jul 2017 00:39:05 -0700
Message-ID: <1500277145.5566.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170714165453.112098-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714165453.112098-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-07-14 at 18:54 +0200, Alexander Potapenko wrote:
> KMSAN reported use of uninitialized memory in skb_set_hash_from_sk(),
> which originated from the TCP request socket created in
> cookie_v6_check():

>  ==================================================================
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> ---
>  net/ipv6/syncookies.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 7b75b0620730..b4b354502c6e 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -216,6 +216,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>  	treq->rcv_isn = ntohl(th->seq) - 1;
>  	treq->snt_isn = cookie;
>  	treq->ts_off = 0;
> +	treq->txhash = 0;
>  
>  	/*
>  	 * We need to lookup the dst_entry to get the correct window size.

Please use net_tx_rndhash() instead of 0, thanks.

( And same fix is needed for IPv4, as Neal mentioned already )
