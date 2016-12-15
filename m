From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 2/2] net/sched: cls_flower: Use masked key when
 calling HW offloads
Date: Thu, 15 Dec 2016 14:50:44 +0100
Message-ID: <20161215135043.GA7104@penelope.horms.nl>
References: <1481734858-37474-1-git-send-email-paulb@mellanox.com>
 <1481734858-37474-3-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38312 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752273AbcLONur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 08:50:47 -0500
Received: by mail-wm0-f51.google.com with SMTP id f82so46766568wmf.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 05:50:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481734858-37474-3-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul,

On Wed, Dec 14, 2016 at 07:00:58PM +0200, Paul Blakey wrote:
> Zero bits on the mask signify a "don't care" on the corresponding bits
> in key. Some HWs require those bits on the key to be zero. Since these
> bits are masked anyway, it's okay to provide the masked key to all
> drivers.
> 
> Fixes: 5b33f48842fa ('net/flower: Introduce hardware offload support')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

While I don't have a specific use case in mind that this change would break
it seems to me that it would be better to handle hardware requirements
at the driver level.

> ---
>  net/sched/cls_flower.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
> index 9758f5a..35ac28d 100644
> --- a/net/sched/cls_flower.c
> +++ b/net/sched/cls_flower.c
> @@ -252,7 +252,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
>  	offload.cookie = (unsigned long)f;
>  	offload.dissector = dissector;
>  	offload.mask = mask;
> -	offload.key = &f->key;
> +	offload.key = &f->mkey;
>  	offload.exts = &f->exts;
>  
>  	tc->type = TC_SETUP_CLSFLOWER;
> -- 
> 1.8.3.1
> 
