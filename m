From: David Miller <davem@davemloft.net>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Fri, 25 Oct 2013 18:18:09 -0400 (EDT)
Message-ID: <20131025.181809.348808013109842304.davem@davemloft.net>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	<1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	<1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab3JYWSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 18:18:11 -0400
In-Reply-To: <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 25 Oct 2013 02:09:00 -0700

> @@ -1252,6 +1252,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  	const struct net_offload *ops;
>  	unsigned int offset = 0;
>  	struct iphdr *iph;
> +	bool udpfrag;
>  	bool tunnel;
>  	int proto;
>  	int nhoff;
> @@ -1306,10 +1307,11 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  	if (IS_ERR_OR_NULL(segs))
>  		goto out;
>  
> +	udpfrag = !!skb->encapsulation && proto == IPPROTO_UDP;
>  	skb = segs;
>  	do {
>  		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> -		if (!tunnel && proto == IPPROTO_UDP) {
> +		if (udpfrag) {
>  			iph->id = htons(id);
>  			iph->frag_off = htons(offset >> 3);
>  			if (skb->next != NULL)
> 

The "tunnel" variable becomes unused once you do this, please remove it.
