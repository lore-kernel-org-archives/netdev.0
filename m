From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH] since the definition of dst_discard_in and dst_discard_out are the same,
Date: Sun, 3 Jun 2007 11:11:46 +0800
Message-ID: <91b13c310706022011tb3fd221x53e47c92fa69fb62@mail.gmail.com>
References: <4660d133.4d65d79b.64d5.72fc@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:35239 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763065AbXFCDLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 23:11:48 -0400
Received: by ug-out-1314.google.com with SMTP id j3so491850ugf
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2007 20:11:46 -0700 (PDT)
In-Reply-To: <4660d133.4d65d79b.64d5.72fc@mx.google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/2/07, Denis Cheng <crquan@gmail.com> wrote:
> they should merged into one
this patch I have checked, it's not corrupted, I wonder someone can
give some comment on this?

>
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  net/core/dst.c |   17 ++++-------------
>  1 files changed, 4 insertions(+), 13 deletions(-)
>
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 764bccb..c6a0587 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -111,13 +111,7 @@ out:
>         spin_unlock(&dst_lock);
>  }
>
> -static int dst_discard_in(struct sk_buff *skb)
> -{
> -       kfree_skb(skb);
> -       return 0;
> -}
> -
> -static int dst_discard_out(struct sk_buff *skb)
> +static int dst_discard(struct sk_buff *skb)
>  {
>         kfree_skb(skb);
>         return 0;
> @@ -138,8 +132,7 @@ void * dst_alloc(struct dst_ops * ops)
>         dst->ops = ops;
>         dst->lastuse = jiffies;
>         dst->path = dst;
> -       dst->input = dst_discard_in;
> -       dst->output = dst_discard_out;
> +       dst->input = dst->output = dst_discard;
>  #if RT_CACHE_DEBUG >= 2
>         atomic_inc(&dst_total);
>  #endif
> @@ -153,8 +146,7 @@ static void ___dst_free(struct dst_entry * dst)
>            protocol module is unloaded.
>          */
>         if (dst->dev == NULL || !(dst->dev->flags&IFF_UP)) {
> -               dst->input = dst_discard_in;
> -               dst->output = dst_discard_out;
> +               dst->input = dst->output = dst_discard;
>         }
>         dst->obsolete = 2;
>  }
> @@ -242,8 +234,7 @@ static inline void dst_ifdown(struct dst_entry *dst, struct net_device *dev,
>                 return;
>
>         if (!unregister) {
> -               dst->input = dst_discard_in;
> -               dst->output = dst_discard_out;
> +               dst->input = dst->output = dst_discard;
>         } else {
>                 dst->dev = &loopback_dev;
>                 dev_hold(&loopback_dev);
> --
> 1.4.4.2
>
>


-- 
Denis Cheng
Linux Application Developer
