From: David Miller <davem@davemloft.net>
Subject: Re: GRO/GSO hiding PMTU?
Date: Thu, 10 Feb 2011 15:07:59 -0800 (PST)
Message-ID: <20110210.150759.59671055.davem@davemloft.net>
References: <20110210.145555.39165146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110210.145555.39165146.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Thu, 10 Feb 2011 14:55:55 -0800 (PST)

> I suspect that the packet arrives on eth1, accumulates into GRO, and
> thus marked as GSO as well, then GSO/TSO on output to eth0 is
> re-segmenting things transparently, and we're not getting the ICMP
> frag-needed message and the packet drop because of the skb_is_gso()
> check in ip_forward().
> 
> 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
> 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
> 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
> 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
> 			  htonl(dst_mtu(&rt->dst)));
> 		goto drop;
> 	}
> 
> So if that's what is happening, that's cute, but I think we need to
> fix this :-)
> 
> Perhaps the check in ip_forward() should instead validate the gso_size
> in the skb_is_gso() case?
> 
> That'd be a little tricky since gso_size is an MSS value whereas what
> we're checking against (skb->len) is the full packet size, headers and
> all.

Nevermind, I turned off gso/tso on eth0 (outgoing interface) and it still
happens.

I guess netfilter or something else is causing this.

