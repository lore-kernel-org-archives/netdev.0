From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: SYNPROXY: fix process non tcp packet bug in
 {ipv4,ipv6}_synproxy_hook
Date: Thu, 24 Aug 2017 16:07:34 +0200
Message-ID: <20170824140734.GA2250@salvia>
References: <1501221784-18226-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kadlec@blackhole.kfki.hu, fw@strlen.de,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501221784-18226-1-git-send-email-xiaolou4617@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2017 at 02:03:04PM +0800, Lin Zhang wrote:
> In function {ipv4,ipv6}_synproxy_hook we expect a normal tcp packet,
> but the real server maybe reply an icmp error packet related to the 
> exist tcp conntrack, so we will access wrong tcp data.
> 
> For fix it, we simply pass IP_CT_RELATED_REPLY packets.
> 
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
> ---
>  net/ipv4/netfilter/ipt_SYNPROXY.c  | 2 +-
>  net/ipv6/netfilter/ip6t_SYNPROXY.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
> index f1528f7..3971fd9 100644
> --- a/net/ipv4/netfilter/ipt_SYNPROXY.c
> +++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
> @@ -330,7 +330,7 @@ static unsigned int ipv4_synproxy_hook(void *priv,
>  	if (synproxy == NULL)
>  		return NF_ACCEPT;
>  
> -	if (nf_is_loopback_packet(skb))
> +	if (nf_is_loopback_packet(skb) || ctinfo == IP_CT_RELATED_REPLY)

If the intention is to inspect TCP traffic only, I would suggest you
just check for the protocol field here instead. So we are sure we only
deal with TCP traffic indeed.

Thanks.
