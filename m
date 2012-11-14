From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH 03/13] net: Add net protocol offload registration
 infrustructure
Date: Wed, 14 Nov 2012 08:08:32 -0500
Message-ID: <50A397D0.4040406@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com> <1352856254-29667-4-git-send-email-vyasevic@redhat.com> <50A354C6.20805@6wind.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36396 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422804Ab2KNNIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 08:08:36 -0500
In-Reply-To: <50A354C6.20805@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2012 03:22 AM, Nicolas Dichtel wrote:
> Le 14/11/2012 02:24, Vlad Yasevich a =C3=A9crit :
>> diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
>> index 8918eff..1278db8 100644
>> --- a/net/ipv4/protocol.c
>> +++ b/net/ipv4/protocol.c
>> @@ -29,6 +29,7 @@
>>   #include <net/protocol.h>
>>
>>   const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS]
>> __read_mostly;
>> +const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS]
>> __read_mostly;
>>
>>   /*
>>    *    Add a protocol handler to the hash tables
>> @@ -41,6 +42,13 @@ int inet_add_protocol(const struct net_protocol
>> *prot, unsigned char protocol)
>>   }
>>   EXPORT_SYMBOL(inet_add_protocol);
>>
>> +int inet_add_offload(const struct net_offload *prot, unsigned char
>> protocol)
>> +{
>> +    return !cmpxchg((const struct net_offload
>> **)&inet_offloads[protocol],
>> +            NULL, prot) ? 0 : -1;
>> +}
>> +EXPORT_SYMBOL(inet_add_offload);
>> +
>>   /*
>>    *    Remove a protocol from the hash tables.
>>    */
>> @@ -56,4 +64,16 @@ int inet_del_protocol(const struct net_protocol
>> *prot, unsigned char protocol)
>>
>>       return ret;
>>   }
>> -EXPORT_SYMBOL(inet_del_protocol);
> This line should probably not be removed ;-)

Yep,  good catch... thanks...

-vald
