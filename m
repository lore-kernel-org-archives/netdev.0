From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: fix looped (broad|multi)cast's bogus MACs in
 NFQUEUE
Date: Wed, 8 Jun 2011 17:30:32 +0200
Message-ID: <20110608153032.GA26912@Chamillionaire.breakpoint.cc>
References: <20110608151817.C95E24587D@pc11-132.lri.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110608151817.C95E24587D@pc11-132.lri.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nicolas Cavallari <Nicolas.Cavallari@lri.fr> wrote:
> By default, when broadcast or multicast packet are sent from a local
> application, they are sent to the interface then looped by the kernel
> to other local applications, going throught netfilter hooks in the process.
> 
> These looped packet have their MAC header removed from the skb by the kernel
> looping code.
> This confuse netfilter's netlink queue because it tries to extract a hardware
> address from these packets, but extracts a part of the IP header instead.

[..]

> patch done against 2.6.39.1 but should also apply to nf-next
> ---
> --- linux-2.6.39.1/net/netfilter/nfnetlink_queue.c	2011-06-08 14:43:41.188003302 +0200
> +++ linux-2.6.39.1/net/netfilter/nfnetlink_queue.c	2011-06-08 14:46:10.892003541 +0200
> @@ -335,7 +335,8 @@ nfqnl_build_packet_message(struct nfqnl_
>  	if (entskb->mark)
>  		NLA_PUT_BE32(skb, NFQA_MARK, htonl(entskb->mark));
>  
> -	if (indev && entskb->dev) {
> +	if (indev && entskb->dev &&
> +	    entskb->network_header != entskb->mac_header) {

nfnetlink_log has the same problem.
