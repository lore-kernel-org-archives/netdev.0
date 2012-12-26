From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ndisc: Ensure to reserve header space for encapsulation.
Date: Thu, 27 Dec 2012 04:08:45 +0900
Message-ID: <50DB4B3D.2050800@linux-ipv6.org>
References: <50D9BAA4.7000207@linux-ipv6.org> <1356540521.20133.20554.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40559 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751812Ab2LZTIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2012 14:08:47 -0500
In-Reply-To: <1356540521.20133.20554.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Tue, 2012-12-25 at 23:39 +0900, YOSHIFUJI Hideaki wrote:
>> We allocate sk_buff of MAX_HEADER + LL_RESERVED_SPACE(dev) + packet
>> length + dev->needed_tailroom, but reserved LL_RESERVED_SPACE(dev)
>> only.  This means that space for encapsulation was placed at the end
>> of buffer.  This does not make sense.
>>
>> Reserve the space correctly, like this:
>>
>> head                       data                   tail       end
>> +--------------------------------------------------------------+
>> +                |           |                      |          |
>> +--------------------------------------------------------------+
>> |<--MAX_HEADER-->|<-hlen---->|<---ipv6 packet------>|<--tlen-->|
>>                    =LL_
>>                     RESERVED_
>>                     SPACE(dev)
>>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
:
> It looks like this MAX_HEADER reserve is not needed at all.
> 
> Space for encapsulation should already be in 
> int hlen = LL_RESERVED_SPACE(dev);
> 
> arp_create() for example doesnt add this MAX_HEADER 
> 
> If extra encapsulation is needed (at head or at tail), it really should
> be documented.

Current code does not make sense, at least.

Please refer to my previous posting: "[GIT PULL net-next 01/17]
ndisc: Fix size calculation for headers." around Dec/19.

My previous patch did remove MAX_HEADER from allocation.

--yoshfuji
