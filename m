From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH] net/ipv4: Move && and || to end of previous
 line
Date: Tue, 24 Nov 2009 00:08:30 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911240004530.19211@melkinpaasi.cs.helsinki.fi>
References: <4B06AC2C.3070102@gmail.com>  <20091120.092651.254794724.davem@davemloft.net> <4B08D967.80003@gmail.com>  <20091122.163112.80105623.davem@davemloft.net> <1259000895.16503.77.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, Netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44178 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755213AbZKWWI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:08:26 -0500
In-Reply-To: <1259000895.16503.77.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Nov 2009, Joe Perches wrote:

> On Sun, 2009-11-22 at 16:31 -0800, David Miller wrote:
> > It should be of the form:
> > 	if (x &&
> > 	    y)
> > 
> > or:
> > 	if (x && y)
> > 
> > Fix patches, rather than complaints, for existing cases where things
> > do not follow this pattern are certainly welcome.
> 
> Also collapsed some multiple tabs to single space.
> 
> Compiled tested only:
> 
>  net/ipv4/inet_lro.c   |   36 ++++++++++++++++++------------------
>  net/ipv4/ip_output.c  |    6 ++++--
>  net/ipv4/ipconfig.c   |   13 ++++++-------
>  net/ipv4/route.c      |   19 ++++++++++---------
>  net/ipv4/tcp_htcp.c   |   10 +++++-----
>  net/ipv4/tcp_input.c  |    4 ++--
>  net/ipv4/tcp_lp.c     |    4 ++--
>  net/ipv4/tcp_output.c |    4 ++--
>  net/ipv4/tcp_probe.c  |    4 ++--
>  net/ipv4/tcp_veno.c   |    5 ++---
>  net/ipv4/tcp_yeah.c   |    4 ++--
>  net/ipv4/udp.c        |   36 ++++++++++++++++++------------------
>  12 files changed, 73 insertions(+), 72 deletions(-)
> 
> diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
> index 6a667da..47038cb 100644
> --- a/net/ipv4/inet_lro.c
> +++ b/net/ipv4/inet_lro.c
> @@ -64,15 +64,15 @@ static int lro_tcp_ip_check(struct iphdr *iph, struct tcphdr *tcph,
>  	if (iph->ihl != IPH_LEN_WO_OPTIONS)
>  		return -1;
>  
> -	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack
> -	    || tcph->rst || tcph->syn || tcph->fin)
> +	if (tcph->cwr || tcph->ece || tcph->urg || !tcph->ack ||
> +	    tcph->rst || tcph->syn || tcph->fin)
>  		return -1;
>  
>  	if (INET_ECN_is_ce(ipv4_get_dsfield(iph)))
>  		return -1;
>  
> -	if (tcph->doff != TCPH_LEN_WO_OPTIONS
> -	    && tcph->doff != TCPH_LEN_W_TIMESTAMP)
> +	if (tcph->doff != TCPH_LEN_WO_OPTIONS &&
> +	    tcph->doff != TCPH_LEN_W_TIMESTAMP)
>  		return -1;
>  
>  	/* check tcp options (only timestamp allowed) */
> @@ -262,10 +262,10 @@ static int lro_check_tcp_conn(struct net_lro_desc *lro_desc,
>  			      struct iphdr *iph,
>  			      struct tcphdr *tcph)
>  {
> -	if ((lro_desc->iph->saddr != iph->saddr)
> -	    || (lro_desc->iph->daddr != iph->daddr)
> -	    || (lro_desc->tcph->source != tcph->source)
> -	    || (lro_desc->tcph->dest != tcph->dest))
> +	if ((lro_desc->iph->saddr != iph->saddr) ||
> +	    (lro_desc->iph->daddr != iph->daddr) ||
> +	    (lro_desc->tcph->source != tcph->source) ||
> +	    (lro_desc->tcph->dest != tcph->dest))
>  		return -1;
>  	return 0;
>  }
> @@ -339,9 +339,9 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
>  	u64 flags;
>  	int vlan_hdr_len = 0;
>  
> -	if (!lro_mgr->get_skb_header
> -	    || lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
> -				       &flags, priv))
> +	if (!lro_mgr->get_skb_header ||
> +	    lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
> +				    &flags, priv))
>  		goto out;
>  
>  	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
> @@ -351,8 +351,8 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
>  	if (!lro_desc)
>  		goto out;
>  
> -	if ((skb->protocol == htons(ETH_P_8021Q))
> -	    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
> +	if ((skb->protocol == htons(ETH_P_8021Q)) &&
> +	    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
>  		vlan_hdr_len = VLAN_HLEN;
>  
>  	if (!lro_desc->active) { /* start new lro session */
> @@ -446,9 +446,9 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
>  	int hdr_len = LRO_MAX_PG_HLEN;
>  	int vlan_hdr_len = 0;
>  
> -	if (!lro_mgr->get_frag_header
> -	    || lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
> -					(void *)&tcph, &flags, priv)) {
> +	if (!lro_mgr->get_frag_header ||
> +	    lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
> +				     (void *)&tcph, &flags, priv)) {
>  		mac_hdr = page_address(frags->page) + frags->page_offset;
>  		goto out1;
>  	}
> @@ -472,8 +472,8 @@ static struct sk_buff *__lro_proc_segment(struct net_lro_mgr *lro_mgr,
>  		if (!skb)
>  			goto out;
>  
> -		if ((skb->protocol == htons(ETH_P_8021Q))
> -		    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
> +		if ((skb->protocol == htons(ETH_P_8021Q)) &&
> +		    !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
>  			vlan_hdr_len = VLAN_HLEN;
>  
>  		iph = (void *)(skb->data + vlan_hdr_len);
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 322b408..b78e615 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -264,9 +264,11 @@ int ip_mc_output(struct sk_buff *skb)
>  
>  		   This check is duplicated in ip_mr_input at the moment.
>  		 */
> -		    && ((rt->rt_flags&RTCF_LOCAL) || !(IPCB(skb)->flags&IPSKB_FORWARDED))
> +		    &&
> +		    ((rt->rt_flags & RTCF_LOCAL) ||
> +		     !(IPCB(skb)->flags & IPSKB_FORWARDED))
>  #endif
> -		) {
> +		   ) {

Certainly better in general already but there is still some work to be 
done here as now you have an && only line. I guess it mostly has to do 
with comments but #if... blahblahs could be another type of failure (in 
automation like this).


-- 
 i.
