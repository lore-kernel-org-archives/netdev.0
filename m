From: Simon Horman <horms@verge.net.au>
Subject: Re: linux-next: manual merge of the net tree with the net-current
 tree
Date: Mon, 20 Jun 2011 12:39:52 +0900
Message-ID: <20110620033951.GA2457@verge.net.au>
References: <20110620125616.e319c55c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110620125616.e319c55c.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 20, 2011 at 12:56:16PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net tree got a conflict in
> net/netfilter/ipvs/ip_vs_core.c between commit 8f4e0a18682d ("IPVS netns
> exit causes crash in conntrack") from the net-current tree and commit
> 503cf15a5ecc ("IPVS: rename of netns init and cleanup functions") from
> the net tree.
> 
> Just context changes.  I fixed it up (see below) and can carry the fix as
> necessary.

Thanks.

I think this should all come out in the wash
when Dave merges net-2.6 into net-next-2.6.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/netfilter/ipvs/ip_vs_core.c
> index 24c28d2,2200bae..0000000
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@@ -1945,8 -1945,7 +1945,8 @@@ static void __net_exit __ip_vs_dev_clea
>   {
>   	EnterFunction(2);
>   	net_ipvs(net)->enable = 0;	/* Disable packet reception */
>  +	smp_wmb();
> - 	__ip_vs_sync_cleanup(net);
> + 	ip_vs_sync_net_cleanup(net);
>   	LeaveFunction(2);
>   }
>   
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
