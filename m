From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH 03/13] net: Add net protocol offload registration
 infrustructure
Date: Wed, 14 Nov 2012 21:16:22 -0500
Message-ID: <50A45076.3040905@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com> <1352856254-29667-4-git-send-email-vyasevic@redhat.com> <20121114231452.GH27068@electric-eye.fr.zoreil.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423422Ab2KOCQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 21:16:28 -0500
In-Reply-To: <20121114231452.GH27068@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2012 06:14 PM, Francois Romieu wrote:
> Vlad Yasevich <vyasevic@redhat.com> :
> [...]
>> diff --git a/include/net/protocol.h b/include/net/protocol.h
>> index 929528c..d8ecb17 100644
>> --- a/include/net/protocol.h
>> +++ b/include/net/protocol.h
>> @@ -77,6 +77,15 @@ struct inet6_protocol {
>>   #define INET6_PROTO_GSO_EXTHDR	0x4
>>   #endif
>>
>> +struct net_offload {
>> +	int			(*gso_send_check)(struct sk_buff *skb);
>> +	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
>> +					       netdev_features_t features);
>> +	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
>> +					       struct sk_buff *skb);
>> +	int			(*gro_complete)(struct sk_buff *skb);
>> +};
>
> Would it be worth adding a #14 where packet_offload and net_offload
> share a common offload struct instead of duplicating (currently) identical
> members ?
>

I'll look...  There are some very minor diffs between the structs, so 
one could at least be based on another.

What bugs me more actually is the duplication between IPv4 and IPv6 
lists.  One idea I had before was to have packet_offload be a container
for the array of net_offloads.  We would then have a single set of 
functions to register tcp/udp callbacks for both ipv4 and ipv6.  I might
resurrect that patch and send it for comments as well.

-vlad
