From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Don't unset flowi6_proto in ipxip6_tnl_xmit()
Date: Thu, 01 Sep 2016 23:41:47 -0700 (PDT)
Message-ID: <20160901.234147.2300105032472747034.davem@davemloft.net>
References: <20160826155229.8040-1-elicooper@gmx.com>
        <20160831.135603.430800022553448126.davem@davemloft.net>
        <3c42e6d9-0057-69c3-6135-b32f056201e9@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com
To: elicooper@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45592 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbcIBGls (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 02:41:48 -0400
In-Reply-To: <3c42e6d9-0057-69c3-6135-b32f056201e9@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cooper <elicooper@gmx.com>
Date: Thu, 1 Sep 2016 09:18:04 +0800

> Hello,
> 
> On 2016/9/1 4:56, David Miller wrote:
>> From: Eli Cooper <elicooper@gmx.com>
>> Date: Fri, 26 Aug 2016 23:52:29 +0800
>>
>>> @@ -1174,6 +1174,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
>>>  		encap_limit = t->parms.encap_limit;
>>>  
>>>  	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
>>> +	fl6.flowi6_proto = IPPROTO_IPIP;
>> Let's just simply have t->fl have the proto setup properly, just like
>> in GRE.
>>
>> Assigning it explicitly every packet transmit doesn't make much sense.
> 
> I doubt that. Unlike GRE, where the proto must be IPPROTO_GRE, the proto
> here can be either IPPROTO_IPV6 or IPPROTO_IPIP for a single tunnel, and
> t->fl is shared by them. Thus it has to be assigned for every packet.

You're right.  Patch applied, thanks for explaining.
