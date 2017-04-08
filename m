From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/1 v2] skbuff: Extend gso_type to unsigned int.
Date: Sat, 08 Apr 2017 11:55:32 -0700
Message-ID: <1491677732.10124.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1491676584-22421-1-git-send-email-steffen.klassert@secunet.com>
         <1491676584-22421-2-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34187 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752837AbdDHSzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 14:55:35 -0400
Received: by mail-io0-f195.google.com with SMTP id n76so10329910ioe.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 11:55:35 -0700 (PDT)
In-Reply-To: <1491676584-22421-2-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-04-08 at 20:36 +0200, Steffen Klassert wrote:
> All available gso_type flags are currently in use, so
> extend gso_type from 'unsigned short' to 'unsigned int'
> to be able to add further flags.
> 
> We reorder the struct skb_shared_info to use
> two bytes of the four byte hole before dataref.
> All fields before dataref are cleared, i.e.
> four bytes more than before the change.
> 
> The remaining two byte hole is moved to the
> beginning of the structure, this protects us
> from immediate overwites on out of bound writes
> to the sk_buff head.

> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/linux/skbuff.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index c776abd..741d75c 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -413,14 +413,15 @@ struct ubuf_info {
>   * the end of the header data, ie. at skb->end.
>   */
>  struct skb_shared_info {
> +	unsigned short	_unused;
>  	unsigned char	nr_frags;
>  	__u8		tx_flags;
>  	unsigned short	gso_size;
>  	/* Warning: this field is not always filled in (UFO)! */
>  	unsigned short	gso_segs;
> -	unsigned short  gso_type;
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
> +	unsigned int	gso_type;
>  	u32		tskey;
>  	__be32          ip6_frag_id;
>  

This looks much better, thanks Steffen.

Acked-by: Eric Dumazet <edumazet@google.com>
