From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] skbuff: optimize the pull_pages code in
 __pskb_pull_tail()
Date: Thu, 06 Jul 2017 02:16:27 -0700
Message-ID: <1499332587.16045.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1499331694-34678-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499331694-34678-1-git-send-email-xiaolou4617@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-07-06 at 17:01 +0800, Lin Zhang wrote:
> In the pull_pages code block, if the first frags size > eat,
> we can end the loop in advance to avoid extra copy.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
> ---
>  net/core/skbuff.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index f990eb8..c00a1df 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -1720,6 +1720,10 @@ void *__pskb_pull_tail(struct sk_buff *skb, int delta)
>  				skb_shinfo(skb)->frags[k].page_offset += eat;
>  				skb_frag_size_sub(&skb_shinfo(skb)->frags[k], eat);
>  				eat = 0;
> +				if (!i) {
> +					k = skb_shinfo(skb)->nr_frags;
> +					break;
> +				}
>  			}
>  			k++;
>  		}

1) net-next is closed during merge window.

2) This change is completely buggy.
   How have you tested it exactly ???
