From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 18/34] ipvs: prevent mixing heterogeneous pools and synchronization
Date: Mon, 29 Sep 2014 20:17:26 +0400
Message-ID: <54298616.7080307@cogentembedded.com>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org> <1411994363-8451-19-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-19-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2014 04:39 PM, Pablo Neira Ayuso wrote:

> From: Alex Gartrell <agartrell@fb.com>

> The synchronization protocol is not compatible with heterogeneous pools, so
> we need to verify that we're not turning both on at the same time.

> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> Acked-by: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Simon Horman <horms@verge.net.au>
> ---
>   include/net/ip_vs.h            |    4 ++++
>   net/netfilter/ipvs/ip_vs_ctl.c |   15 +++++++++++++++
>   2 files changed, 19 insertions(+)

> diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
> index 7600dbe..576d7f0 100644
> --- a/include/net/ip_vs.h
> +++ b/include/net/ip_vs.h
> @@ -990,6 +990,10 @@ struct netns_ipvs {
>   	char			backup_mcast_ifn[IP_VS_IFNAME_MAXLEN];
>   	/* net name space ptr */
>   	struct net		*net;            /* Needed by timer routines */
> +	/* Number of heterogeneous destinations, needed because
> +	 * heterogeneous are not supported when synchronization is
> +	 * enabled */

    Multi-line comment style in the networking code is:

/* bla
  * bla
  */


> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 6bd2cc6..462760e 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
[...]
> @@ -3256,6 +3265,12 @@ static int ip_vs_genl_new_daemon(struct net *net, struct nlattr **attrs)
>   	      attrs[IPVS_DAEMON_ATTR_SYNC_ID]))
>   		return -EINVAL;
>
> +	/* The synchronization protocol is incompatible with mixed family
> +	 * services
> +	 */

    Here you got it right. :-)

> +	if (net_ipvs(net)->mixed_address_family_dests > 0)
> +		return -EINVAL;
> +

WBR, Sergei

