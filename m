From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next] sctp: support ipv6 nonlocal bind
Date: Fri, 22 Jul 2016 10:31:56 -0300
Message-ID: <20160722133156.GD9950@localhost.localdomain>
References: <b3a6fd04f36bcfc5557d70ba79cddfc9c5d33b3c.1469180331.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803AbcGVNcB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 09:32:01 -0400
Content-Disposition: inline
In-Reply-To: <b3a6fd04f36bcfc5557d70ba79cddfc9c5d33b3c.1469180331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 05:38:51PM +0800, Xin Long wrote:
> This patch makes sctp support ipv6 nonlocal bind by adding
> sp->inet.freebind and net->ipv6.sysctl.ip_nonlocal_bind
> check in sctp_v6_available as what sctp did to support
> ipv4 nonlocal bind (commit cdac4e077489).

Next time please mention the commit summary, e.g.
cdac4e077489 ("[SCTP] Add support for ip_nonlocal_bind sysctl &
IP_FREEBIND socket option")
For now I think we can infer it from the changelog just fine, unless
Dave thinks otherwise.

> 
> Reported-by: Shijoe George <spanjikk@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/ipv6.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index ae6f1a2..660c4a4 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -560,6 +560,7 @@ static int sctp_v6_is_any(const union sctp_addr *addr)
>  static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
>  {
>  	int type;
> +	struct net *net = sock_net(&sp->inet.sk);
>  	const struct in6_addr *in6 = (const struct in6_addr *)&addr->v6.sin6_addr;
>  
>  	type = ipv6_addr_type(in6);
> @@ -574,7 +575,8 @@ static int sctp_v6_available(union sctp_addr *addr, struct sctp_sock *sp)
>  	if (!(type & IPV6_ADDR_UNICAST))
>  		return 0;
>  
> -	return ipv6_chk_addr(sock_net(&sp->inet.sk), in6, NULL, 0);
> +	return sp->inet.freebind || net->ipv6.sysctl.ip_nonlocal_bind ||
> +		ipv6_chk_addr(net, in6, NULL, 0);
>  }
>  
>  /* This function checks if the address is a valid address to be used for
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
