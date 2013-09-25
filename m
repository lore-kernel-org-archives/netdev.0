From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 1/3] flow_dissector: factor out the ports
 extraction in skb_flow_get_ports
Date: Thu, 26 Sep 2013 01:50:22 +0200
Message-ID: <524376BE.5010506@redhat.com>
References: <1380133912-1240-1-git-send-email-nikolay@redhat.com> <1380133912-1240-2-git-send-email-nikolay@redhat.com> <52437454.6020407@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993Ab3IYXuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 19:50:35 -0400
In-Reply-To: <52437454.6020407@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 01:40 AM, Nikolay Aleksandrov wrote:
> On 09/25/2013 08:31 PM, Nikolay Aleksandrov wrote:
>> Factor out the code that extracts the ports from skb_flow_dissect and
>> add a new function skb_flow_get_ports which can be re-used.
>>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> v2: new patch
>> This seems like a good idea because there're other users that can re-use
>> it later as well.
>>
>>  include/net/flow_keys.h   |  1 +
>>  net/core/flow_dissector.c | 38 +++++++++++++++++++++++++++-----------
>>  2 files changed, 28 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
>> index ac2439d..621bf11 100644
>> --- a/include/net/flow_keys.h
>> +++ b/include/net/flow_keys.h
>> @@ -14,4 +14,5 @@ struct flow_keys {
>>  };
>>  
>>  bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
>> +__be32 skb_flow_get_ports(const struct sk_buff *skb, int nhoff, u8 ip_proto);
>>  #endif
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index 1929af8..c609faf 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -25,9 +25,34 @@ static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *i
>>  	memcpy(&flow->src, &iph->saddr, sizeof(flow->src) + sizeof(flow->dst));
>>  }
>>  
>> +/**
>> + * skb_flow_get_ports - extract the upper layer ports and return them
>> + * @skb: buffer to extract the ports from
>> + * @nhoff: network header offset
> I hurried too much, this should've said "offset to the end of the network
> header" i.e. nhoff + sizeof(network header), I'll wait until tomorrow to
> see if there aren't any other comments and will edit this and re-post a v3.
> 
> Nik
> 
Ugh, nevermind this email, I'm going crazy about semantics today :-)
Everything is fine.
