From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/10] netfilter: add nf_ct_kfree_compat_sysctl_table
 to make codes clear
Date: Thu, 14 Jun 2012 20:06:32 +0200
Message-ID: <20120614180632.GD10633@1984>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339668445-23848-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339668445-23848-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2012 at 06:07:18PM +0800, Gao feng wrote:
> add function nf_ct_kfree_compat_sysctl_table to kfree l4proto's
> compat sysctl table and set the sysctl table point to NULL.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_l4proto.h |    8 ++++++++
>  net/netfilter/nf_conntrack_proto.c           |    4 +---
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
> index 5dd60f2..889b717 100644
> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> @@ -132,6 +132,14 @@ extern int nf_ct_port_nlattr_to_tuple(struct nlattr *tb[],
>  extern int nf_ct_port_nlattr_tuple_size(void);
>  extern const struct nla_policy nf_ct_port_nla_policy[];
>  
> +static inline void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
> +{
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
> +	kfree(pn->ctl_compat_table);
> +	pn->ctl_compat_table = NULL;
> +#endif
> +}
> +
>  #ifdef CONFIG_SYSCTL
>  #ifdef DEBUG_INVALID_PACKETS
>  #define LOG_INVALID(net, proto)				\
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 8fc0332..c9df1b4 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -361,9 +361,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
>  					    NULL);
>  		if (err == 0)
>  			goto out;
> -
> -		kfree(pn->ctl_compat_table);
> -		pn->ctl_compat_table = NULL;
> +		nf_ct_kfree_compat_sysctl_table(pn);

if this is the only client of this function, then make it static and
define it inside nf_conntrack_proto.c

>  		nf_ct_unregister_sysctl(&pn->ctl_table_header,
>  					&pn->ctl_table,
>  					&pn->users);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
