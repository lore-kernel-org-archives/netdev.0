From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net] ipv4: fix nexthop attlen check in fib_nh_match
Date: Mon, 13 Oct 2014 05:22:46 -0700
Message-ID: <1413202966.9362.80.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413194063-10354-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:54070 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaJMMWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 08:22:50 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so5606415pdj.12
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 05:22:48 -0700 (PDT)
In-Reply-To: <1413194063-10354-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-13 at 11:54 +0200, Jiri Pirko wrote:
> fib_nh_match does not match nexthops correctly. Example:
> 
> This command is not successful and route is removed. After this patch
> applied, the route is correctly matched and result is:
> RTNETLINK answers: No such process
> 
> Please consider this for stable trees as well.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv4/fib_semantics.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 5b6efb3..f99f41b 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -537,7 +537,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
>  			return 1;
>  
>  		attrlen = rtnh_attrlen(rtnh);
> -		if (attrlen < 0) {
> +		if (attrlen > 0) {
>  			struct nlattr *nla, *attrs = rtnh_attrs(rtnh);
>  
>  			nla = nla_find(attrs, attrlen, RTA_GATEWAY);

Fixes: 4e902c57417c4 ("[IPv4]: FIB configuration using struct fib_config")

Good catch, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
