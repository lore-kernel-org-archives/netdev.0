From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] ip6_output: fragment outgoing reassembled
 skb properly
Date: Thu, 07 Nov 2013 18:54:53 -0500 (EST)
Message-ID: <20131107.185453.1341640661253119352.davem@davemloft.net>
References: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
	<1383756740-7392-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: jiri@resnulli.us
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383756740-7392-2-git-send-email-jiri@resnulli.us>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  6 Nov 2013 17:52:19 +0100

> If reassembled packet would fit into outdev MTU, it is not fragmented
> according the original frag size and it is send as single big packet.
> 
> The second case is if skb is gso. In that case fragmentation does not happen
> according to the original frag size.
> 
> This patch fixes these.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
 ...

>  	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
> -	    dst_allfrag(skb_dst(skb)))
> +	    dst_allfrag(skb_dst(skb)) ||
> +	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
>  		return ip6_fragment(skb, ip6_finish_output2);

Jiri are you sure that you don't need to take GSO into account in the
new part you are adding to the test?
