From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: macvlan: Remove duplicated IFF_UP
 condition check in macvlan_forward_source_one
Date: Sun, 20 Nov 2016 09:37:56 -0800
Message-ID: <1479663476.8455.369.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479640879-30733-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35782 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbcKTRh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 12:37:58 -0500
Received: by mail-pg0-f65.google.com with SMTP id p66so26145628pga.2
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 09:37:58 -0800 (PST)
In-Reply-To: <1479640879-30733-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-20 at 19:21 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <gfree.wind@gmail.com>
> 
> The condition check "dev->flags & IFF_UP" is duplicated in
> macvlan_forward_source_one, because its caller macvlan_forward_source
> has already checked this flag.
> 
> Signed-off-by: Gao Feng <gfree.wind@gmail.com>
> ---
>  drivers/net/macvlan.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 13b7e0b..95a5ffc 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -375,9 +375,6 @@ static void macvlan_forward_source_one(struct sk_buff *skb,
>  	int ret;
>  
>  	dev = vlan->dev;
> -	if (unlikely(!(dev->flags & IFF_UP)))
> -		return;
> -
>  	nskb = skb_clone(skb, GFP_ATOMIC);
>  	if (!nskb)
>  		return;

If you don't mind, I would rather remove the test in the caller and
leave it here. It is likely compiler inlines the function anyway, so
there is no performance change.
