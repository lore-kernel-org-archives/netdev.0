From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: rtnl_register in net_ns_init need rtnl_lock
Date: Thu, 22 Sep 2016 06:03:04 -0700
Message-ID: <1474549384.23058.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36859 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcIVNDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 09:03:06 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so3810084pfb.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 06:03:06 -0700 (PDT)
In-Reply-To: <1474542209-28409-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 13:03 +0200, Hannes Frederic Sowa wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  net/core/net_namespace.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 2c2eb1b629b11d..a2ace299f28355 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -758,9 +758,11 @@ static int __init net_ns_init(void)
>  
>  	register_pernet_subsys(&net_ns_ops);
>  
> +	rtnl_lock();
>  	rtnl_register(PF_UNSPEC, RTM_NEWNSID, rtnl_net_newid, NULL, NULL);
>  	rtnl_register(PF_UNSPEC, RTM_GETNSID, rtnl_net_getid, rtnl_net_dumpid,
>  		      NULL);
> +	rtnl_unlock();
>  
>  	return 0;
>  }

Hi Hannes

Why is this needed here, and not in other places ?

Hint : A changelog always help reviewers and future bug hunting.

Thanks.
