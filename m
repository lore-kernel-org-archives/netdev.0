From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] use skb_end_offset() in skb_try_coalesce()
Date: Mon, 01 Oct 2012 19:28:37 +0200
Message-ID: <1349112517.12401.715.camel@edumazet-glaptop>
References: <6f3540c213735f009409d1cc7d3fe0dea91469d9.1348899174.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53895 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab2JAR2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 13:28:43 -0400
Received: by bkcjk13 with SMTP id jk13so5111627bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 10:28:42 -0700 (PDT)
In-Reply-To: <6f3540c213735f009409d1cc7d3fe0dea91469d9.1348899174.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-09-29 at 14:15 +0800, Weiping Pan wrote:
> Commit ec47ea824774(skb: Add inline helper for getting the skb end offset from
> head) introduces this helper function, skb_end_offset(),
> we should make use of it.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>
> ---
>  net/core/skbuff.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index e33ebae..86f040a 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3488,8 +3488,7 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>  		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
>  			return false;
>  
> -		delta = from->truesize -
> -			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
> +		delta = from->truesize - SKB_TRUESIZE(skb_end_offset(from));
>  	}
>  
>  	WARN_ON_ONCE(delta < len);

Acked-by: Eric Dumazet <edumazet@google.com>
