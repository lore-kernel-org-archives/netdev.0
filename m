From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH 01/13] net:  Add generic packet offload infrastructure.
Date: Wed, 14 Nov 2012 08:03:42 -0500
Message-ID: <50A396AE.5090608@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>  <1352856254-29667-2-git-send-email-vyasevic@redhat.com> <1352859861.4497.0.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2534 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422711Ab2KNNDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 08:03:44 -0500
In-Reply-To: <1352859861.4497.0.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2012 09:24 PM, Eric Dumazet wrote:
> On Tue, 2012-11-13 at 20:24 -0500, Vlad Yasevich wrote:
>> Create a new data structure to contain the GRO/GSO callbacks and add
>> a new registration mechanism.
>>
>> Singed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   include/linux/netdevice.h |   15 ++++++++
>>   net/core/dev.c            |   80 +++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 95 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index f8eda02..d15af51 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1511,6 +1511,18 @@ struct packet_type {
>>   	struct list_head	list;
>>   };
>>
>> +struct packet_offload {
>> +	__be16			type;	/* This is really htons(ether_type). */
>> +	struct net_device	*dev;	/* NULL is wildcarded here	     */
>
> Shouldnt this dev pointer be removed at some point in the patch serie ?

yes.  i was thinking about this as well.  I actually shouldn't have been 
carried into this struct to begin with since its not really being used 
by the offload calls.

-vlad

>
>> +	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
>> +						netdev_features_t features);
>> +	int			(*gso_send_check)(struct sk_buff *skb);
>> +	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
>> +					       struct sk_buff *skb);
>> +	int			(*gro_complete)(struct sk_buff *skb);
>> +	struct list_head	list;
>> +};
>> +
>>   #include <linux/notifier.h>
>>
>
