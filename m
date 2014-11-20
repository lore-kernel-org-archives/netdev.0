From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: use skb_get_hash_raw instead of
 skb_get_hash in set_rps_cpu
Date: Wed, 19 Nov 2014 16:51:40 -0800
Message-ID: <CA+mtBx9K61KmguzQBWNbnmesCvWtzh_SjjbjedkgxN6p4Oay4Q@mail.gmail.com>
References: <1416391244-27390-1-git-send-email-_govind@gmx.com>
	<20141119.191610.1447608233879904907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: _govind@gmx.com, Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:55712 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbaKTAvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 19:51:41 -0500
Received: by mail-ig0-f179.google.com with SMTP id r2so1989377igi.0
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 16:51:41 -0800 (PST)
In-Reply-To: <20141119.191610.1447608233879904907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 4:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Wed, 19 Nov 2014 15:30:44 +0530
>
>> In set_rps_cpu, we call skb_get_hash to get the hash of skb. The caller
>> get_rps_cpu has already determined the hash of skb by calling skb_get_hash.
>>
>> Since get_rps_cpu is the only caller of set_rps_cpu, we can use skb_get_hash_raw
>>
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>
> Tom, please review.  And if you agree with this change, you'll need to
> be spinning your flow_id change relative to this I guess since it overlaps.
>
We should probably pass hash as an argument in set_rps_cpu. It's only
called from once place and the rflow is specifically chosen based on
hash computed by caller-- don't want any ambiguity there.

>> ---
>>  net/core/dev.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 1ab168e..b4ad4d1 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -3055,7 +3055,7 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
>>               flow_table = rcu_dereference(rxqueue->rps_flow_table);
>>               if (!flow_table)
>>                       goto out;
>> -             flow_id = skb_get_hash(skb) & flow_table->mask;
>> +             flow_id = skb_get_hash_raw(skb) & flow_table->mask;
>>               rc = dev->netdev_ops->ndo_rx_flow_steer(dev, skb,
>>                                                       rxq_index, flow_id);
>>               if (rc < 0)
>> --
>> 2.1.0
>>
