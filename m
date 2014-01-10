From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 08/23] netfilter: nft_ct: load both IPv4 and IPv6 conntrack
 modules for NFPROTO_INET
Date: Fri, 10 Jan 2014 23:40:38 +0300
Message-ID: <52D05AC6.20000@cogentembedded.com>
References: <1389314142-17969-1-git-send-email-pablo@netfilter.org> <1389314142-17969-9-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1389314142-17969-9-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/2014 03:35 AM, Pablo Neira Ayuso wrote:

> From: Patrick McHardy <kaber@trash.net>

> The ct expression can currently not be used in the inet family since
> we don't have a conntrack module for NFPROTO_INET, so
> nf_ct_l3proto_try_module_get() fails. Add some manual handling to
> load the modules for both NFPROTO_IPV4 and NFPROTO_IPV6 if the
> ct expression is used in the inet family.

> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>   net/netfilter/nft_ct.c |   39 ++++++++++++++++++++++++++++++++++++---
>   1 file changed, 36 insertions(+), 3 deletions(-)

> diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
> index 955f4e6..3727a32 100644
> --- a/net/netfilter/nft_ct.c
> +++ b/net/netfilter/nft_ct.c
[...]
> +static void nft_ct_l3proto_module_put(uint8_t family)
> +{
> +	if (family == NFPROTO_INET) {
> +		nf_ct_l3proto_module_put(NFPROTO_IPV4);
> +		nf_ct_l3proto_module_put(NFPROTO_IPV6);
> +	} else
> +		nf_ct_l3proto_module_put(family);

    According to Documentation/CodingStyle, there should be {} in the *else* 
arm, as the other arm of *if* statement has it.

> +}
> +

WBR, Sergei

