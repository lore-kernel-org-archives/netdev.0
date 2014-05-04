From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipv4: "conntrack zones" support for defrag user check in
 ip_expire
Date: Sun, 4 May 2014 13:18:50 +0200
Message-ID: <20140504111850.GA3765@localhost>
References: <536426BC.7020509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Florian Westphal <fw@strlen.de>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vasily Averin <vvs@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <536426BC.7020509@parallels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 03, 2014 at 03:14:04AM +0400, Vasily Averin wrote:
> Defrag user check in ip_expire was not updated after adding support for
> "conntrack zones"

I think this bug manifests as a RFC violation, as the router will send
the icmp time exceeeded message when using conntrack zones. Just would
like to confirm this, so we can include it in the patch description.
Thanks.

> Signed-off-by: Vasily Averin <vvs@openvz.org>
> ---
>  net/ipv4/ip_fragment.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index c10a3ce..ed32313 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -232,8 +232,9 @@ static void ip_expire(unsigned long arg)
>  		 * "Fragment Reassembly Timeout" message, per RFC792.
>  		 */
>  		if (qp->user == IP_DEFRAG_AF_PACKET ||
> -		    (qp->user == IP_DEFRAG_CONNTRACK_IN &&
> -		     skb_rtable(head)->rt_type != RTN_LOCAL))
> +		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
> +		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) &&
> +		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
>  			goto out_rcu_unlock;
>  
>  
> -- 
> 1.7.5.4
> 
