From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 23 Mar 2015 13:47:23 +0100
Message-ID: <20150323124723.GA6740@salvia>
References: <20150323140841.0b807b95@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150323140841.0b807b95@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2015 at 02:08:41PM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> net/netfilter/nf_tables_core.c between commit 4017a7ee693d ("netfilter:
> restore rule tracing via nfnetlink_log") from the net tree and commit
> 01ef16c2dd2e ("netfilter: nf_tables: minor tracing cleanups") from the
> net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

This looks good, thanks for adressing this conflict Stephen.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc net/netfilter/nf_tables_core.c
> index 2d298dccb6dd,77165bf023f3..000000000000
> --- a/net/netfilter/nf_tables_core.c
> +++ b/net/netfilter/nf_tables_core.c
> @@@ -21,6 -21,48 +21,48 @@@
>   #include <net/netfilter/nf_tables.h>
>   #include <net/netfilter/nf_log.h>
>   
> + enum nft_trace {
> + 	NFT_TRACE_RULE,
> + 	NFT_TRACE_RETURN,
> + 	NFT_TRACE_POLICY,
> + };
> + 
> + static const char *const comments[] = {
> + 	[NFT_TRACE_RULE]	= "rule",
> + 	[NFT_TRACE_RETURN]	= "return",
> + 	[NFT_TRACE_POLICY]	= "policy",
> + };
> + 
> + static struct nf_loginfo trace_loginfo = {
> + 	.type = NF_LOG_TYPE_LOG,
> + 	.u = {
> + 		.log = {
> + 			.level = 4,
> + 			.logflags = NF_LOG_MASK,
> + 	        },
> + 	},
> + };
> + 
> + static void __nft_trace_packet(const struct nft_pktinfo *pkt,
> + 			       const struct nft_chain *chain,
> + 			       int rulenum, enum nft_trace type)
> + {
> + 	struct net *net = dev_net(pkt->in ? pkt->in : pkt->out);
> + 
>  -	nf_log_packet(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
>  -		      pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
>  -		      chain->table->name, chain->name, comments[type],
>  -		      rulenum);
> ++	nf_log_trace(net, pkt->xt.family, pkt->ops->hooknum, pkt->skb, pkt->in,
> ++		     pkt->out, &trace_loginfo, "TRACE: %s:%s:%s:%u ",
> ++		     chain->table->name, chain->name, comments[type],
> ++		     rulenum);
> + }
> + 
> + static inline void nft_trace_packet(const struct nft_pktinfo *pkt,
> + 				    const struct nft_chain *chain,
> + 				    int rulenum, enum nft_trace type)
> + {
> + 	if (unlikely(pkt->skb->nf_trace))
> + 		__nft_trace_packet(pkt, chain, rulenum, type);
> + }
> + 
>   static void nft_cmp_fast_eval(const struct nft_expr *expr,
>   			      struct nft_data data[NFT_REG_MAX + 1])
>   {
