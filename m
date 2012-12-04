From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [net-next:master 153/162] net/ipv6/addrconf.c:503:11: error:
 'struct ipv6_devconf' has no member named 'mc_forwarding'
Date: Tue, 04 Dec 2012 21:00:11 +0100
Message-ID: <50BE564B.6040507@6wind.com>
References: <50be5189.raDtevqQSzQSZzon%fengguang.wu@intel.com> <20121204.144702.1067637950249633761.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61092 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab2LDUAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:00:16 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1825884bkw.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:00:13 -0800 (PST)
In-Reply-To: <20121204.144702.1067637950249633761.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/12/2012 20:47, David Miller a =E9crit :
>
> Thanks, fixed as follows:
>
> --------------------
> [PATCH] ipv6: Protect ->mc_forwarding access with CONFIG_IPV6_MROUTE
>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
Sorry for that and thank you for the fix and the report.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

> ---
>   net/ipv6/addrconf.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 28e0e62..6fca01f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -469,8 +469,10 @@ static int inet6_netconf_msgsize_devconf(int typ=
e)
>   	/* type -1 is used for ALL */
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_FORWARDING)
>   		size +=3D nla_total_size(4);
> +#ifdef CONFIG_IPV6_MROUTE
>   	if (type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING)
>   		size +=3D nla_total_size(4);
> +#endif
>
>   	return size;
>   }
> @@ -498,11 +500,12 @@ static int inet6_netconf_fill_devconf(struct sk=
_buff *skb, int ifindex,
>   	if ((type =3D=3D -1 || type =3D=3D NETCONFA_FORWARDING) &&
>   	    nla_put_s32(skb, NETCONFA_FORWARDING, devconf->forwarding) < 0=
)
>   		goto nla_put_failure;
> +#ifdef CONFIG_IPV6_MROUTE
>   	if ((type =3D=3D -1 || type =3D=3D NETCONFA_MC_FORWARDING) &&
>   	    nla_put_s32(skb, NETCONFA_MC_FORWARDING,
>   			devconf->mc_forwarding) < 0)
>   		goto nla_put_failure;
> -
> +#endif
>   	return nlmsg_end(skb, nlh);
>
>   nla_put_failure:
