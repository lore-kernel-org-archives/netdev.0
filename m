From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 04/12] net: Make generic dst->child usage more
 explicit.
Date: Wed, 25 Oct 2017 07:55:17 -0700
Message-ID: <1508943317.30291.123.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171025.230311.1944266209591105385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:45173 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932204AbdJYOzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:55:21 -0400
Received: by mail-pf0-f194.google.com with SMTP id d28so169689pfe.2
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:55:21 -0700 (PDT)
In-Reply-To: <20171025.230311.1944266209591105385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-25 at 23:03 +0900, David Miller wrote:
> Only IPSEC (xfrm) routes have a dst->child which is non-NULL.
> xfrm routes are identified by dst->xfrm being non-NULL.
> 
> Codify this explicitly in dst_destroy().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dst.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 662a2d4a3d19..6a3c21b8fc8d 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -116,12 +116,14 @@ EXPORT_SYMBOL(dst_alloc);
>  
>  struct dst_entry *dst_destroy(struct dst_entry * dst)
>  {
> -	struct dst_entry *child;
> +	struct dst_entry *child = NULL;
>  
>  	smp_rmb();
>  
> -	child = dst->child;
> -
> +#ifdef CONFIG_XFRM
> +	if (dst->xfrm)
> +		child = dst->child;
> +#endif
>  	if (!(dst->flags & DST_NOCOUNT))
>  		dst_entries_add(dst->ops, -1);
>  

You might squash this patch with the following one ;)
