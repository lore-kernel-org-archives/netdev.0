From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix setting csum_start in tcp_gso_segment
Date: Wed, 25 Jun 2014 00:19:04 -0700
Message-ID: <1403680744.3796.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, torvalds@linux-foundation.org,
	davej@redhat.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1406242056330.29780@tomh.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-06-24 at 21:03 -0700, Tom Herbert wrote:

> 
> It looks like a likely culprit is that SKB_GSO_CB()->csum_start is
> not set correctly when doing non-scatter gather. We are using
> offset as opposed to doffset.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/skbuff.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9cd5344..c1a3303 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2993,7 +2993,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  							    skb_put(nskb, len),
>  							    len, 0);
>  			SKB_GSO_CB(nskb)->csum_start =
> -			    skb_headroom(nskb) + offset;
> +			    skb_headroom(nskb) + doffset;
>  			continue;
>  		}
>  

Yes, seems an obvious typo, but please change patch title.

This is not "tcp: fix setting csum_start in tcp_gso_segment"

Maybe "net: fix setting csum_start in skb_segment()"
