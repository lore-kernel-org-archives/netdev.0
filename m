From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: manual merge of the net-next tree with the netfilter
 tree
Date: Thu, 10 Nov 2016 01:31:17 +0100
Message-ID: <20161110003117.GA4285@salvia>
References: <20161110105633.31ebdc76@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        Networking <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110105633.31ebdc76@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thu, Nov 10, 2016 at 10:56:33AM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   net/netfilter/ipvs/ip_vs_ctl.c
> 
> between commit:
> 
>   8fbfef7f505b ("ipvs: use IPVS_CMD_ATTR_MAX for family.maxattr")
> 
> from the netfilter tree and commit:
> 
>   489111e5c25b ("genetlink: statically initialize families")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

I think I cannot help to address this conflict myself.

8fbfef7f505b is in my nf tree, while 489111e5c25b is in net-next. So
you will hit this conflict by when you pull net into net-next.

So please keep this patch from Stephen to resolve the conflict in your
radar to solve this.

Or let me know if you come up with any way I can handle this from here
to reduce your burden. Thanks.

> diff --cc net/netfilter/ipvs/ip_vs_ctl.c
> index a6e44ef2ec9a,6b85ded4f91d..000000000000
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@@ -3872,10 -3865,20 +3865,20 @@@ static const struct genl_ops ip_vs_genl
>   	},
>   };
>   
> + static struct genl_family ip_vs_genl_family __ro_after_init = {
> + 	.hdrsize	= 0,
> + 	.name		= IPVS_GENL_NAME,
> + 	.version	= IPVS_GENL_VERSION,
>  -	.maxattr	= IPVS_CMD_MAX,
> ++	.maxattr	= IPVS_CMD_ATTR_MAX,
> + 	.netnsok        = true,         /* Make ipvsadm to work on netns */
> + 	.module		= THIS_MODULE,
> + 	.ops		= ip_vs_genl_ops,
> + 	.n_ops		= ARRAY_SIZE(ip_vs_genl_ops),
> + };
> + 
>   static int __init ip_vs_genl_register(void)
>   {
> - 	return genl_register_family_with_ops(&ip_vs_genl_family,
> - 					     ip_vs_genl_ops);
> + 	return genl_register_family(&ip_vs_genl_family);
>   }
>   
>   static void ip_vs_genl_unregister(void)
