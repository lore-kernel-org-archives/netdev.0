From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] neigh: reduce arp latency
Date: Tue, 9 Aug 2011 20:06:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108091959250.1527@ja.ssi.bg>
References: <1312904434.2371.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54153 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011Ab1HIRBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 13:01:33 -0400
In-Reply-To: <1312904434.2371.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 9 Aug 2011, Eric Dumazet wrote:

> Remove the artificial HZ latency on arp resolution.
> 
> Instead of firing a timer in one jiffy (up to 10 ms if HZ=100), lets
> send the ARP message immediately.
> 
> @@ -957,7 +964,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
>  			atomic_set(&neigh->probes, neigh->parms->ucast_probes);
>  			neigh->nud_state     = NUD_INCOMPLETE;
>  			neigh->updated = jiffies;
> -			neigh_add_timer(neigh, now + 1);
> +			neigh_add_timer(neigh, now + HZ);

	To be correct with old NUD_INCOMPLETE logic may be we can use 
max(neigh->parms->retrans_time, HZ/2) here instead of HZ?

> +			immediate_probe = true;
>  		} else {
>  			neigh->nud_state = NUD_FAILED;
>  			neigh->updated = jiffies;

Regards

--
Julian Anastasov <ja@ssi.bg>
