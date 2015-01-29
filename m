From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next] net: mark some potential candidates
 __read_mostly
Date: Thu, 29 Jan 2015 16:40:24 +0100
Message-ID: <1422546024.2861.18.camel@redhat.com>
References: <1422530103-23869-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbbA2Pk2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 10:40:28 -0500
In-Reply-To: <1422530103-23869-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2015-01-29 at 12:15 +0100, Daniel Borkmann wrote:
> They are all either written once or extremly rarely (e.g. from init
> code), so we can move them to the .data..read_mostly section.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  drivers/net/ipvlan/ipvlan_core.c | 2 +-
>  net/bridge/br_netlink.c          | 2 +-
>  net/ipv4/devinet.c               | 2 +-
>  net/ipv6/addrconf.c              | 2 +-
>  net/mpls/mpls_gso.c              | 4 ++--
>  5 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index 2e19528..2a17500 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -9,7 +9,7 @@
>  
>  #include "ipvlan.h"
>  
> -static u32 ipvlan_jhash_secret;
> +static u32 ipvlan_jhash_secret __read_mostly;
>  
>  void ipvlan_init_secret(void)
>  {
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 3875ea5..e08b260 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -701,7 +701,7 @@ static size_t br_get_link_af_size(const struct net_device *dev)
>  	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
>  }
>  
> -static struct rtnl_af_ops br_af_ops = {
> +static struct rtnl_af_ops br_af_ops __read_mostly = {
>  	.family			= AF_BRIDGE,
>  	.get_link_af_size	= br_get_link_af_size,
>  };

Why not const?

> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index 59ebe16..f0b4a31 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -2322,7 +2322,7 @@ static __net_initdata struct pernet_operations devinet_ops = {
>  	.exit = devinet_exit_net,
>  };
>  
> -static struct rtnl_af_ops inet_af_ops = {
> +static struct rtnl_af_ops inet_af_ops __read_mostly = {
>  	.family		  = AF_INET,
>  	.fill_link_af	  = inet_fill_link_af,
>  	.get_link_af_size = inet_get_link_af_size,

Const?

> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 7dcc065e..8623118 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -5405,7 +5405,7 @@ static struct pernet_operations addrconf_ops = {
>  	.exit = addrconf_exit_net,
>  };
>  
> -static struct rtnl_af_ops inet6_ops = {
> +static struct rtnl_af_ops inet6_ops __read_mostly = {
>  	.family		  = AF_INET6,
>  	.fill_link_af	  = inet6_fill_link_af,
>  	.get_link_af_size = inet6_get_link_af_size,

Const?

> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index 349295d..809df53 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -60,14 +60,14 @@ out:
>  	return segs;
>  }
>  
> -static struct packet_offload mpls_mc_offload = {
> +static struct packet_offload mpls_mc_offload __read_mostly = {
>  	.type = cpu_to_be16(ETH_P_MPLS_MC),
>  	.callbacks = {
>  		.gso_segment    =	mpls_gso_segment,
>  	},
>  };
>  
> -static struct packet_offload mpls_uc_offload = {
> +static struct packet_offload mpls_uc_offload __read_mostly = {
>  	.type = cpu_to_be16(ETH_P_MPLS_UC),
>  	.callbacks = {
>  		.gso_segment    =	mpls_gso_segment,
