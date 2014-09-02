From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] net: Don't keep around original SKB when we
 software segment GSO frames.
Date: Mon, 01 Sep 2014 18:42:41 -0700 (PDT)
Message-ID: <20140901.184241.1951715714321502017.davem@davemloft.net>
References: <20140901.152515.1944476256109254437.davem@davemloft.net>
	<CA+mtBx-1r-vJYDx0xJ+p=Tjr=_v559XdrSu1SZ4UXWE_4fLbZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbaIBBmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:42:42 -0400
In-Reply-To: <CA+mtBx-1r-vJYDx0xJ+p=Tjr=_v559XdrSu1SZ4UXWE_4fLbZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 1 Sep 2014 18:28:18 -0700

> On Mon, Sep 1, 2014 at 3:25 PM, David Miller <davem@davemloft.net> wrote:
>>  struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev);
>> -int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>> -                       struct netdev_queue *txq);
>> +struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>> +                                   struct netdev_queue *txq, int *ret);
> 
> Might be slightly better to still return int but pass struct sk_buff
> **skb. One less argument and doesn't change return type.

Sure we could do that, I don't have any preference either way and
besides there is only one call site.
