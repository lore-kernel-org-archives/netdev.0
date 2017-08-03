From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] iproute: Display offload indication
 per-nexthop
Date: Thu, 3 Aug 2017 09:16:15 -0700
Message-ID: <20170803091615.3ef64de1@xeon-e3>
References: <20170803061355.6474-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, dsahern@gmail.com,
        mlxsw@mellanox.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35690 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751010AbdHCQQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:16:17 -0400
Received: by mail-pf0-f173.google.com with SMTP id t86so8162692pfe.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 09:16:17 -0700 (PDT)
In-Reply-To: <20170803061355.6474-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  3 Aug 2017 09:13:55 +0300
Ido Schimmel <idosch@mellanox.com> wrote:

> Since kernel commit 475abbf1ef67 ("ipv4: fib: Set offload indication
> according to nexthop flags") offload indication is reported on a
> per-nexthop basis.
> 
> Adjust iproute2 to display it.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  ip/iproute.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/ip/iproute.c b/ip/iproute.c
> index cb695ad..39af38c 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -696,6 +696,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
>  				fprintf(fp, "onlink ");
>  			if (nh->rtnh_flags & RTNH_F_PERVASIVE)
>  				fprintf(fp, "pervasive ");
> +			if (nh->rtnh_flags & RTNH_F_OFFLOAD)
> +				fprintf(fp, "offload ");
>  			if (nh->rtnh_flags & RTNH_F_LINKDOWN)
>  				fprintf(fp, "linkdown ");
>  			len -= NLMSG_ALIGN(nh->rtnh_len);

Yet another set of flags that needs to be table driven..
