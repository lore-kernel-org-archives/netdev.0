From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] net: ipv6: Don't purge default router if accept_ra=2
Date: Mon, 04 Mar 2013 19:09:19 +0900
Message-ID: <513472CF.7020308@linux-ipv6.org>
References: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54279 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756219Ab3CDKJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 05:09:21 -0500
In-Reply-To: <CAKD1Yr2e8Z8CDAM3tgp=nUR58OO9QZYEx8zkWwwcQ1S=14D2Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lorenzo Colitti wrote:
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
> 

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
