From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] crashes with kvm/nat networking and net-next
Date: Thu, 13 May 2010 14:58:56 +0200
Message-ID: <4BEBF790.1040103@trash.net>
References: <20100511202544.267d33ee@nehalam>	<1273649526.2621.3.camel@edumazet-laptop>	<4BEA8E79.9000406@trash.net>	<4BEAB54A.2070203@pandora.be> <20100512151540.6f09a1b8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54922 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab0EMM67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 08:58:59 -0400
In-Reply-To: <20100512151540.6f09a1b8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 12 May 2010 16:03:54 +0200
>> Don't call nf_bridge_update_protocol() for ARP traffic as
>> skb->nf_bridge isn't used in the ARP case.
>>
>>
>> Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
>> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
>> index 93f80fe..4442099 100644
>> --- a/net/bridge/br_netfilter.c
>> +++ b/net/bridge/br_netfilter.c
>> @@ -643,10 +643,10 @@ static int br_nf_forward_finish(struct sk_buff *skb)
>>  			skb->pkt_type = PACKET_OTHERHOST;
>>  			nf_bridge->mask ^= BRNF_PKT_TYPE;
>>  		}
>> +		nf_bridge_update_protocol(skb);
>>  	} else {
>>  		in = *((struct net_device **)(skb->cb));
>>  	}
>> -	nf_bridge_update_protocol(skb);
>>  	nf_bridge_push_encap_header(skb);
>>  
>>  	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
>>
> 
> This has worked all day for me without problem.

Applied, thanks everyone.
