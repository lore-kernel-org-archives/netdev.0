From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [v2 PATCH 1/2] NETFILTER module xt_hmark new target for HASH
 based fw
Date: Mon, 7 Nov 2011 04:36:20 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1111070434220.26514@frira.zrqbmnf.qr>
References: <1317664003-28189-1-git-send-email-hans.schillstrom@ericsson.com> <1317664003-28189-2-git-send-email-hans.schillstrom@ericsson.com> <20111107005237.GA29665@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>, kaber@trash.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20111107005237.GA29665@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday 2011-11-07 01:52, Pablo Neira Ayuso wrote:
>> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
>> +{
>> +	int nhoff, hash = 0, poff, proto, frag = 0;
>> +	struct iphdr *ip;
>> +	u8 ip_proto;
>> +	u32 addr1, addr2, ihl;
>> +	u16 snatport = 0, dnatport = 0;
>> +	union {
>> +		u32 v32;
>> +		u16 v16[2];
>> +	} ports;
>> +
>> +	nhoff = skb_network_offset(skb);
>> +	proto = skb->protocol;
>> +
>> +	if (!proto && skb->sk) {
>> +		if (skb->sk->sk_family == AF_INET)
>> +			proto = __constant_htons(ETH_P_IP);
>> +		else if (skb->sk->sk_family == AF_INET6)
>> +			proto = __constant_htons(ETH_P_IPV6);
>
>You already have the layer3 protocol number in xt_action_param. No
>need to use the socket information then.

xt_action_param.family (NFPROTO_) is not the same class af AF_ or ETH_.
Though, wouldn't proto = skb->proto; just be simpler here?
