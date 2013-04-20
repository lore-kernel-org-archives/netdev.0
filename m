From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2] packet: tx timestamping on tpacket ring
Date: Sat, 20 Apr 2013 18:43:59 +0200
Message-ID: <20130420164359.GA10333@netboy>
References: <CA+FuTSdGdhgpRARbv9zFnDESzCQBzT=DS-WgGZRWBLBvhN_sNg@mail.gmail.com>
 <1366408317-16432-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, paul.chavent@onera.fr,
	daniel.borkmann@tik.ee.ethz.ch
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33241 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755469Ab3DTQoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Apr 2013 12:44:11 -0400
Received: by mail-wi0-f170.google.com with SMTP id l13so2538799wie.3
        for <netdev@vger.kernel.org>; Sat, 20 Apr 2013 09:44:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1366408317-16432-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 05:51:57PM -0400, Willem de Bruijn wrote:

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 898cf5c..af9185d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3327,12 +3327,8 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>  	if (!sk)
>  		return;
>  
> -	skb = skb_clone(orig_skb, GFP_ATOMIC);
> -	if (!skb)
> -		return;
> -
>  	if (hwtstamps) {
> -		*skb_hwtstamps(skb) =
> +		*skb_hwtstamps(orig_skb) =
>  			*hwtstamps;

And how does *hwtstamps get into the clone?

>  	} else {
>  		/*
> @@ -3340,9 +3336,13 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>  		 * so keep the shared tx_flags and only
>  		 * store software time stamp
>  		 */
> -		skb->tstamp = ktime_get_real();
> +		orig_skb->tstamp = ktime_get_real();
>  	}
>  
> +	skb = skb_clone(orig_skb, GFP_ATOMIC);
> +	if (!skb)
> +		return;
> +
>  	serr = SKB_EXT_ERR(skb);
>  	memset(serr, 0, sizeof(*serr));
>  	serr->ee.ee_errno = ENOMSG;

Thanks,
Richard
