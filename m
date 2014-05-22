From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] ipv4: initialise the itag variable in __mkroute_input
Date: Thu, 22 May 2014 09:03:36 -0700
Message-ID: <CAADnVQ+bvNGhrEqC3P3DqApjcXM3OUUHqTWJ+iwVmC3f4PguEw@mail.gmail.com>
References: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roy.qing.li@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	dormando <dormando@rydia.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:54496 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932AbaEVQDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 12:03:37 -0400
Received: by mail-qc0-f180.google.com with SMTP id i17so5988557qcy.39
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 09:03:36 -0700 (PDT)
In-Reply-To: <1400747815-3470-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 22, 2014 at 1:36 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> the value of itag is a random value from stack, and may not be initiated by
> fib_validate_source, which called fib_combine_itag if CONFIG_IP_ROUTE_CLASSID
> is not set
>
> This will make the cached dst uncertainty
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Nice catch. Indeed. I think it's needed for stable.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Dormando,
can you check whether your config has CONFIG_IP_ROUTE_CLASSID or not?
The way I'm reading the code, it shouldn't be causing your failures,
but that part
of code is hairy..

> ---
>  net/ipv4/route.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 50e1e0f..4154eb7 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1526,7 +1526,7 @@ static int __mkroute_input(struct sk_buff *skb,
>         struct in_device *out_dev;
>         unsigned int flags = 0;
>         bool do_cache;
> -       u32 itag;
> +       u32 itag = 0;
>
>         /* get a working reference to the output device */
>         out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
