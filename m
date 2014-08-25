From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Allow raw buffers to be passed into the flow
 dissector.
Date: Mon, 25 Aug 2014 16:14:38 -0700 (PDT)
Message-ID: <20140825.161438.1566152288868625745.davem@davemloft.net>
References: <20140823.121855.1259915921868754968.davem@davemloft.net>
	<CAHA+R7NTcRiOrP=M5=i8NkTHYZ3-RT8w-J5FPNsDh88c7yYKvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, idos@mellanox.com, eric.dumazet@gmail.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933648AbaHYXOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:14:39 -0400
In-Reply-To: <CAHA+R7NTcRiOrP=M5=i8NkTHYZ3-RT8w-J5FPNsDh88c7yYKvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 25 Aug 2014 16:13:01 -0700

> On Sat, Aug 23, 2014 at 12:18 PM, David Miller <davem@davemloft.net> wrote:
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 5f362c1..660c649 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -34,29 +34,40 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
>>   * The function will try to retrieve the ports at offset thoff + poff where poff
>>   * is the protocol port offset returned from proto_ports_offset
>>   */
>> -__be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto)
>> +__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
>> +                           void *data, int hlen)
> 
> 
> You forgot to update the comments above __skb_flow_get_ports(),
> not a big deal, I will send a patch if you don't. ;-)

Please do, thanks.

> Not sure if I read your patch correctly, I think our goal is to make
> skb parameter
> optional so that callers can pass NULL if they don't have a skb struct?
> __skb_flow_dissect() still refers skb->protocol at least.

The idea is that explicit *data and hlen can be provided in absense of
an SKB.

I see the skb->protocol reference, I guess we'll need to provide an
explicit protocol argument as well, good catch!
