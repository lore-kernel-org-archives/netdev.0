From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2] tc: flower: Fix flower output for src and dst
 ports
Date: Tue, 24 Jan 2017 09:42:19 +0100
Message-ID: <20170124084217.GA30193@penelope.horms.nl>
References: <1484490229-19712-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>
To: Roi Dayan <roid@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38454 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAXImX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 03:42:23 -0500
Received: by mail-wm0-f41.google.com with SMTP id r144so196544352wme.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 00:42:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484490229-19712-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 04:23:49PM +0200, Roi Dayan wrote:
> This fix a missing use case after the introduction of enum flower_endpoint.
> 
> Fixes: 6910d65661a3 ("tc: flower: introduce enum flower_endpoint")
> Signed-off-by: Roi Dayan <roid@mellanox.com>
> Signed-off-by: Paul Blakey <paulb@mellanox.com>

Thanks, sorry for missing that:

Reviewed-by: Simon Horman <simon.horman@netronome.com>

> ---
>  tc/f_flower.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tc/f_flower.c b/tc/f_flower.c
> index 71e9515..1dbc532 100644
> --- a/tc/f_flower.c
> +++ b/tc/f_flower.c
> @@ -744,10 +744,10 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
>  			     tb[TCA_FLOWER_KEY_IPV6_SRC],
>  			     tb[TCA_FLOWER_KEY_IPV6_SRC_MASK]);
>  
> -	nl_type = flower_port_attr_type(ip_proto, false);
> +	nl_type = flower_port_attr_type(ip_proto, FLOWER_ENDPOINT_DST);
>  	if (nl_type >= 0)
>  		flower_print_port(f, "dst_port", tb[nl_type]);
> -	nl_type = flower_port_attr_type(ip_proto, true);
> +	nl_type = flower_port_attr_type(ip_proto, FLOWER_ENDPOINT_SRC);
>  	if (nl_type >= 0)
>  		flower_print_port(f, "src_port", tb[nl_type]);
>  
> -- 
> 1.7.1
> 
