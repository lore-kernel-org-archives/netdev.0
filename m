From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v2 2/3] netlink: implement nla_policy for HW QOS
Date: Thu, 02 Dec 2010 11:53:37 -0800
Message-ID: <4CF7F941.6080701@intel.com>
References: <20101201182252.2748.15208.stgit@jf-dev1-dcblab> <20101201182258.2748.99569.stgit@jf-dev1-dcblab> <20101202102037.GB10221@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:45340 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab0LBTxi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 14:53:38 -0500
In-Reply-To: <20101202102037.GB10221@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/2/2010 2:20 AM, Thomas Graf wrote:
> On Wed, Dec 01, 2010 at 10:22:58AM -0800, John Fastabend wrote:
>> +
>> +		NLA_PUT_U8(skb, IFLA_TC_TXMAX, dev->max_tcs);
>> +		NLA_PUT_U8(skb, IFLA_TC_TXNUM, dev->num_tcs);
>> +
>> +		tc_txq = nla_nest_start(skb, IFLA_TC_TXQS);
> 
> You have to check the return value here.
> 
>> +		for (i = 0; i < dev->num_tcs; i++) {
>> +			tcq = netdev_get_tc_queue(dev, i);
>> +			ifla_tcq.tc = i;
>> +			ifla_tcq.count = tcq->count;
>> +			ifla_tcq.offset = tcq->offset;
>> +
>> +			NLA_PUT(skb, IFLA_TC_TXQ, sizeof(ifla_tcq), &ifla_tcq);
>> +		}
>> +		nla_nest_end(skb, tc_txq);
>> +
>> +		tc_map = nla_nest_start(skb, IFLA_TC_MAPS);
> 
> Same here
> 
>> +		for (i = 0; i < 16; i++) {
>> +			ifla_map.prio = i;
>> +			ifla_map.tc = netdev_get_prio_tc_map(dev, i);
>> +			NLA_PUT(skb, IFLA_TC_MAP, sizeof(ifla_map), &ifla_map);
>> +		}
>>  
>> +
>> +static const struct nla_policy ifla_tc_txq[IFLA_TC_TXQS_MAX+1] = {
>> +	[IFLA_TC_TXQ]		= { .type = NLA_BINARY,
>> +				    .len = sizeof(struct ifla_tc_txq)},
> 
> This is probably not what you want. NLA_BINARY only enforces a maximum
> payload length but no minimum payload length.
> 
> Omit the .type and let it fall back to NLA_UNSPEC and only specify a
> .len. This enforces that the attribute payload is at least .len in
> length. You should not worry about payload that exceeds your size
> expectations. This allows to extend ifla_tc_txq in the future.
> 
>> +static const struct nla_policy ifla_tc_map[IFLA_TC_MAPS_MAX+1] = {
>> +	[IFLA_TC_MAP]		= { .type = NLA_BINARY,
>> +				    .len = sizeof(struct ifla_tc_map)},
>> +};
> 
> Same here


errors noted. Thanks for the clarification I'll fix this up. Also I'll look into Jamal's comment regarding moving this to use 'tc'.

-- John  
