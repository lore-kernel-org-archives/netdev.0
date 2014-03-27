From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_conntrack: reserve two bytes for
 nf_ct_ext->len
Date: Thu, 27 Mar 2014 15:45:05 +0000
Message-ID: <20140327154504.GC31944@macbook.localnet>
References: <1395934354-13226-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, vvs@parallels.com,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1395934354-13226-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2014 at 07:32:34PM +0400, Andrey Vagin wrote:
> "len" contains sizeof(nf_ct_ext) and size of extensions. In a worst
> case it can contain all extensions. Bellow you can find sizes for all
> types of extensions. Their sum is definitely bigger than 256.
> 
> nf_ct_ext_types[0]->len = 24
> nf_ct_ext_types[1]->len = 32
> nf_ct_ext_types[2]->len = 24
> nf_ct_ext_types[3]->len = 32
> nf_ct_ext_types[4]->len = 152
> nf_ct_ext_types[5]->len = 2
> nf_ct_ext_types[6]->len = 16
> nf_ct_ext_types[7]->len = 8
> 
> I have seen "len" up to 280 and my host has crashes w/o this patch.

Very nice catch. I suppose we also need to either increase the size of
offset[] or rearrange the extension so 4 (ECACHE) comes last.

> 
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  include/net/netfilter/nf_conntrack_extend.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
> index 956b175..36fd6bf 100644
> --- a/include/net/netfilter/nf_conntrack_extend.h
> +++ b/include/net/netfilter/nf_conntrack_extend.h
> @@ -48,7 +48,7 @@ enum nf_ct_ext_id {
>  struct nf_ct_ext {
>  	struct rcu_head rcu;
>  	u8 offset[NF_CT_EXT_NUM];
> -	u8 len;
> +	u16 len;
>  	char data[0];
>  };
>  
> -- 
> 1.8.5.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
