From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] Set the correct RTNL family for multicast netconf messages
Date: Fri, 28 Jun 2013 03:23:07 +0200
Message-ID: <20130628012307.GB15799@order.stressinduktion.org>
References: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"nicolas.dichtel@6wind.com" <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Davison <Mike.Davison@vyatta.com>
To: Sven-Thorsten Dietrich <sven@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1372376687.21767.10.camel@imac-linux.luckyscavenger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 27, 2013 at 04:44:47PM -0700, Sven-Thorsten Dietrich wrote:
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index dfc39d4..695858b 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1705,7 +1705,16 @@ static int inet_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
>  		return -EMSGSIZE;
>  
>  	ncm = nlmsg_data(nlh);
> -	ncm->ncm_family = AF_INET;
> +
> +	switch (type) {
> +		case NETCONFA_MC_FORWARDING:
> +			ncm->ncm_family = RTNL_FAMILY_IPMR;
> +			break;
> +
> +		default:
> +			ncm->ncm_family = AF_INET;
> +			break;
> +	}
>  
>  	if (nla_put_s32(skb, NETCONFA_IFINDEX, ifindex) < 0)
>  		goto nla_put_failure;
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4ab4c38..a177da4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -492,7 +492,16 @@ static int inet6_netconf_fill_devconf(struct sk_buff *skb, int ifindex,
>  		return -EMSGSIZE;
>  
>  	ncm = nlmsg_data(nlh);
> -	ncm->ncm_family = AF_INET6;
> +
> +	switch (type) {
> +		case NETCONFA_MC_FORWARDING:
> +			ncm->ncm_family = RTNL_FAMILY_IP6MR;
> +			break;
> +
> +		default:
> +			ncm->ncm_family = AF_INET6;
> +			break;
> +	}
>  

Hm, are you sure? NETCONFA_MC_FORWARDING is of type RTM_NEWNETCONF
and expects ncm_family to be either AF_INET or AF_INET6 (at least in
iproute2/ipmonitor.c).

Greetings,

  Hannes
