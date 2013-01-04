From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ndisc: Remove unused space at tail of skb for
 ndisc messages. (TAKE 3)
Date: Fri, 04 Jan 2013 15:17:10 -0800 (PST)
Message-ID: <20130104.151710.601442706907153024.davem@davemloft.net>
References: <50E6DFEC.7080603@linux-ipv6.org>
	<1357315219.1678.1461.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749Ab3ADXRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 18:17:11 -0500
In-Reply-To: <1357315219.1678.1461.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 Jan 2013 08:00:19 -0800

> On Fri, 2013-01-04 at 22:58 +0900, YOSHIFUJI Hideaki wrote:
>> Currently, the size of skb allocated for NDISC is MAX_HEADER +
>> LL_RESERVED_SPACE(dev) + packet length + dev->needed_tailroom,
>> but only LL_RESERVED_SPACE(dev) bytes is "reserved" for headers.
>> As a result, the skb looks like this (after construction of the
>> message):
>> 
>> head       data                   tail                       end
>> +--------------------------------------------------------------+
>> +           |                      |          |                |
>> +--------------------------------------------------------------+
>> |<-hlen---->|<---ipv6 packet------>|<--tlen-->|<--MAX_HEADER-->|
>>     =LL_                               = dev
>>      RESERVED_                           ->needed_
>>      SPACE(dev)                            tailroom
>> 
>> As the name implies, "MAX_HEADER" is used for headers, and should
>> be "reserved" in prior to packet construction.  Or, if some space
>> is really required at the tail of ther skb, it should be
>> explicitly documented.
>> 
>> We have several option after construction of NDISC message:
>> 
>> Option 1:
>> 
>> head       data                   tail       end
>> +---------------------------------------------+
>> +           |                      |          |
>> +---------------------------------------------+
>> |<-hlen---->|<---ipv6 packet------>|<--tlen-->|
>>    =LL_                                = dev
>>     RESERVED_                           ->needed_
>>     SPACE(dev)                            tailroom
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for your persistence.
