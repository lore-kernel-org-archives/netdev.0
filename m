From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: place in source hash after SNAT is done
Date: Mon, 15 Nov 2010 12:07:33 +0100
Message-ID: <4CE11475.30905@trash.net>
References: <1289796483-2970-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1289796483-2970-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.11.2010 05:48, Changli Gao wrote:
> If SNAT isn't done, the wrong info maybe got by the other cts.
> 
> As the filter table is after DNAT table, the packets dropped in filter
> table also bother bysource hash table.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/ipv4/netfilter/nf_nat_core.c |   18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
> index c04787c..51ce55a 100644
> --- a/net/ipv4/netfilter/nf_nat_core.c
> +++ b/net/ipv4/netfilter/nf_nat_core.c
> @@ -545,11 +550,10 @@ static void nf_nat_move_storage(void *new, void *old)
>  	struct nf_conn_nat *old_nat = old;
>  	struct nf_conn *ct = old_nat->ct;
>  
> -	if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
> +	if (!ct || !(ct->status & IPS_SRC_NAT_DONE))
>  		return;
>  
>  	spin_lock_bh(&nf_nat_lock);
> -	new_nat->ct = ct;

Why are you removing this?
