From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH net-next 1/5]IPv6:netfilter: defrag:Introduce net
 namespace to conntrack and share netns_frags with IPv6 stack
Date: Wed, 24 Feb 2010 16:07:31 +0100
Message-ID: <4B8540B3.8080404@trash.net>
References: <4B84C235.4070601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B84C235.4070601@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> Introduce net namespace to conntrack and share netns_frags with IPv6 stack.  
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    7 +-
>  net/ipv6/netfilter/nf_conntrack_reasm.c        |   79 +++++++-----------------
>  2 files changed, 25 insertions(+), 61 deletions(-)
> 
> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> index 996c3f4..f153b2c 100644
> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> @@ -221,7 +221,10 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
>  	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
>  		return NF_ACCEPT;
>  
> +	local_bh_disable();
>  	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
> +	local_bh_enable();

Please seperate any locking changes from the introduction
of network namespaces.

