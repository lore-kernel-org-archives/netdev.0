From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  [v2 PATCH 1/2] NETFILTER module xt_hmark new target
	for HASH based fw
Date: Mon, 7 Nov 2011 23:14:38 +0100 (CET)
Message-ID: <0hivdsb.17b7b3e4ecaab40c6692abe7114c9f3a@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Pablo Neira Ayuso" <pablo@netfilter.org>,
	"Hans Schillstrom" <hans.schillstrom@ericsson.com>,
	kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Jan Engelhardt" <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello
>
>On Monday 2011-11-07 01:52, Pablo Neira Ayuso wrote:
>>> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
>>> +{
>>> +	int nhoff, hash = 0, poff, proto, frag = 0;
>>> +	struct iphdr *ip;
>>> +	u8 ip_proto;
>>> +	u32 addr1, addr2, ihl;
>>> +	u16 snatport = 0, dnatport = 0;
>>> +	union {
>>> +		u32 v32;
>>> +		u16 v16[2];
>>> +	} ports;
>>> +
>>> +	nhoff = skb_network_offset(skb);
>>> +	proto = skb->protocol;
>>> +
>>> +	if (!proto && skb->sk) {
>>> +		if (skb->sk->sk_family == AF_INET)
>>> +			proto = __constant_htons(ETH_P_IP);
>>> +		else if (skb->sk->sk_family == AF_INET6)
>>> +			proto = __constant_htons(ETH_P_IPV6);
>>
>>You already have the layer3 protocol number in xt_action_param. No
>>need to use the socket information then.
>
>xt_action_param.family (NFPROTO_) is not the same class af AF_ or ETH_.
>Though, wouldn't proto = skb->proto; just be simpler here?

Well it's not always set ...

I think I will split the get_hash() into  get_ipv4_hash() and get_ipv6_hash()
as Pablo suggest in prev mail. 
In that case it would be no cost to use xt_action_param ->family to separate  IPv6 / 4  

Thanks
Hans

