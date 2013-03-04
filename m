From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] net: ipv6: Don't purge default router if accept_ra=2
Date: Mon, 04 Mar 2013 06:58:55 -0800
Message-ID: <1362409135.15793.93.camel@edumazet-glaptop>
References: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:64508 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870Ab3CDO67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 09:58:59 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so3139399pbc.39
        for <netdev@vger.kernel.org>; Mon, 04 Mar 2013 06:58:58 -0800 (PST)
In-Reply-To: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 15:46 +0900, Lorenzo Colitti wrote:
> Setting net.ipv6.conf.<interface>.accept_ra=2 causes the kernel
> to accept RAs even when forwarding is enabled. However, enabling
> forwarding purges all default routes on the system, breaking
> connectivity until the next RA is received. Fix this by not
> purging default routes on interfaces that have accept_ra=2.
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv6/route.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 9282665..e5fe004 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1915,7 +1915,8 @@ void rt6_purge_dflt_routers(struct net *net)
>  restart:
>  	read_lock_bh(&table->tb6_lock);
>  	for (rt = table->tb6_root.leaf; rt; rt = rt->dst.rt6_next) {
> -		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) {
> +		if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF) &&
> +		    (!rt->rt6i_idev || rt->rt6i_idev->cnf.accept_ra != 2)) {
>  			dst_hold(&rt->dst);
>  			read_unlock_bh(&table->tb6_lock);
>  			ip6_del_rt(rt);

Acked-by: Eric Dumazet <edumazet@google.com>
