From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/2] ip6_output: fragment outgoing reassembled
 skb properly
Date: Fri, 8 Nov 2013 08:52:01 +0100
Message-ID: <20131108075201.GA2455@minipsycho.orion>
References: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
 <1383756740-7392-2-git-send-email-jiri@resnulli.us>
 <20131107.185453.1341640661253119352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131107.185453.1341640661253119352.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Nov 08, 2013 at 12:54:53AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed,  6 Nov 2013 17:52:19 +0100
>
>> If reassembled packet would fit into outdev MTU, it is not fragmented
>> according the original frag size and it is send as single big packet.
>> 
>> The second case is if skb is gso. In that case fragmentation does not happen
>> according to the original frag size.
>> 
>> This patch fixes these.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ...
>
>>  	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
>> -	    dst_allfrag(skb_dst(skb)))
>> +	    dst_allfrag(skb_dst(skb)) ||
>> +	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
>>  		return ip6_fragment(skb, ip6_finish_output2);
>
>Jiri are you sure that you don't need to take GSO into account in the
>new part you are adding to the test?


For gso skb, we need co cap outgoing fragments by the original frag size
as well. So I believe that this code is correct for that case as well.

>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
