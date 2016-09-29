From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the netfilter-next tree with the
 net tree
Date: Thu, 29 Sep 2016 11:20:14 +1000
Message-ID: <20160929112014.4293728d@canb.auug.org.au>
References: <20160913101250.0ffee30f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Liping Zhang <liping.zhang@spreadtrum.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160913101250.0ffee30f@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On Tue, 13 Sep 2016 10:12:50 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> Today's linux-next merge of the netfilter-next tree got a conflict in:
> 
>   net/netfilter/nf_tables_netdev.c
> 
> between commit:
> 
>   c73c24849011 ("netfilter: nf_tables_netdev: remove redundant ip_hdr assignment")
> 
> from the net tree and commit:
> 
>   ddc8b6027ad0 ("netfilter: introduce nft_set_pktinfo_{ipv4, ipv6}_validate()")
> 
> from the netfilter-next tree.
> 
> I fixed it up (I used the latter version of this file and applied the
> patch below) and can carry the fix as necessary. This is now fixed as
> far as linux-next is concerned, but any non trivial conflicts should be
> mentioned to your upstream maintainer when your tree is submitted for
> merging.  You may also want to consider cooperating with the maintainer
> of the conflicting tree to minimise any particularly complex conflicts.
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 13 Sep 2016 10:08:58 +1000
> Subject: [PATCH] netfilter: merge fixup for "nf_tables_netdev: remove
>  redundant ip_hdr assignment"
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/net/netfilter/nf_tables_ipv4.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/net/netfilter/nf_tables_ipv4.h b/include/net/netfilter/nf_tables_ipv4.h
> index 968f00b82fb5..25e33aee91e7 100644
> --- a/include/net/netfilter/nf_tables_ipv4.h
> +++ b/include/net/netfilter/nf_tables_ipv4.h
> @@ -33,7 +33,6 @@ __nft_set_pktinfo_ipv4_validate(struct nft_pktinfo *pkt,
>  	if (!iph)
>  		return -1;
>  
> -	iph = ip_hdr(skb);
>  	if (iph->ihl < 5 || iph->version != 4)
>  		return -1;
>  
> -- 
> 2.8.1

The above merge fix patch is now needed when the net-next tree is
merged with Linus' tree.

-- 
Cheers,
Stephen Rothwell
