From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 33/34] netfilter: nf_tables: store and dump set policy
Date: Mon, 29 Sep 2014 20:14:59 +0400
Message-ID: <54298583.3020100@cogentembedded.com>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org> <1411994363-8451-34-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-34-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2014 04:39 PM, Pablo Neira Ayuso wrote:

> From: Arturo Borrero <arturo.borrero.glez@gmail.com>

> We want to know in which cases the user explicitly sets the policy
> options. In that case, we also want to dump back the info.

> Signed-off-by: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>   include/net/netfilter/nf_tables.h |    2 ++
>   net/netfilter/nf_tables_api.c     |    6 ++++++
>   2 files changed, 8 insertions(+)

> diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
> index c4d8619..3d72923 100644
> --- a/include/net/netfilter/nf_tables.h
> +++ b/include/net/netfilter/nf_tables.h
[...]
> index a476b99..19e79f0 100644
> --- a/net/netfilter/nf_tables_api.c
> +++ b/net/netfilter/nf_tables_api.c
> @@ -2344,6 +2344,11 @@ static int nf_tables_fill_set(struct sk_buff *skb, const struct nft_ctx *ctx,
>   			goto nla_put_failure;
>   	}
>
> +	if (set->policy != NFT_SET_POL_PERFORMANCE) {
> +		if (nla_put_be32(skb, NFTA_SET_POLICY, htonl(set->policy)))
> +			goto nla_put_failure;

    Why not fold these two *if* stetement into a single one?

WBR, Sergei

