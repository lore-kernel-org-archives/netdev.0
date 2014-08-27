From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: add skb_get_tx_queue() helper
Date: Wed, 27 Aug 2014 11:12:50 +0200
Message-ID: <53FDA112.3090005@redhat.com>
References: <1409087208-25809-1-git-send-email-dborkman@redhat.com> <CA+mtBx855UwnZsRwn3ugLU35gzrL0=7WD9G6g43MgVST86oWhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886AbaH0JM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:12:56 -0400
In-Reply-To: <CA+mtBx855UwnZsRwn3ugLU35gzrL0=7WD9G6g43MgVST86oWhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 01:51 AM, Tom Herbert wrote:
> On Tue, Aug 26, 2014 at 2:06 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> Replace occurences of skb_get_queue_mapping() and follow-up
>> netdev_get_tx_queue() with an actual helper function.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   include/linux/netdevice.h | 8 ++++++++
>>   net/core/netpoll.c        | 2 +-
>>   net/core/pktgen.c         | 4 +---
>>   net/packet/af_packet.c    | 4 +---
>>   net/sched/sch_generic.c   | 6 ++++--
>>   5 files changed, 15 insertions(+), 9 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 039b237..200ee4f 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1747,6 +1747,14 @@ struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
>>          return &dev->_tx[index];
>>   }
>>
>> +static inline struct netdev_queue *skb_get_tx_queue(const struct net_device *dev,
>> +                                                   const struct sk_buff *skb)
>> +{
>> +       u16 index = skb_get_queue_mapping(skb);
>> +
>> +       return netdev_get_tx_queue(dev, index);
>> +}
>> +
> return netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
>
> if you want to be a little more concise.

That's fine by me too, lets keep it a one-liner.
