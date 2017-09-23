From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/6] rtnetlink: add helper to dump ifalias
Date: Sat, 23 Sep 2017 14:04:50 -0700
Message-ID: <1506200690.29839.217.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170923192636.3932-1-fw@strlen.de>
         <20170923192636.3932-4-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34173 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIWVEx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 17:04:53 -0400
Received: by mail-pg0-f68.google.com with SMTP id u18so2658951pgo.1
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 14:04:52 -0700 (PDT)
In-Reply-To: <20170923192636.3932-4-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-09-23 at 21:26 +0200, Florian Westphal wrote:
> Reviewed-by: David Ahern <dsahern@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Changes since v3: don't add rtnl assertion, I placed the assertion
>  in my working tree instead as a reminder.
> 
>  net/core/rtnetlink.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index c801212ee40e..47c17c3de79a 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1332,6 +1332,14 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
>  	return nla_put_u32(skb, IFLA_LINK, ifindex);
>  }
>  
> +static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)


Why noinline here ?

This function does not use stack at all (and that would call for
noinline_for_stack )

> +{
> +	if (dev->ifalias)
> +		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
> +
> +	return 0;
> +}
> +

I really do not see the point of not making this RCU aware right away,
or at least make it in the same patch series...
