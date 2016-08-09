From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 11:36:10 +0200
Message-ID: <147361af-2984-02e8-aff3-6b53b5e98b39@stressinduktion.org>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net>
 <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net>
 <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <d8cd5324-3beb-1afd-37fe-7e4c1e6c4de2@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Erik Kline <ek@google.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:47707 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932165AbcHIJgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 05:36:13 -0400
In-Reply-To: <d8cd5324-3beb-1afd-37fe-7e4c1e6c4de2@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.08.2016 10:37, YOSHIFUJI Hideaki wrote:
> 
> 
> Erik Kline wrote:
>> On 9 August 2016 at 14:20, David Miller <davem@davemloft.net> wrote:
>>> From: Lorenzo Colitti <lorenzo@google.com>
>>> Date: Tue, 9 Aug 2016 10:00:25 +0900
>>>
>>>> Note that pretty much every sendmsg codepath allows other data to take
>>>> precedence over sk_bound_dev_if:
>>>>
>>>> - udpv6_sendmsg: if sin6_scope_id specified on a scoped address
>>>> - rawv6_sendmsg: if sin6_scope_id specified on a scoped address
>>>> - l2tp_ip6_sendmsg: if sin6_scope_id specified on a scoped address
>>>> - ip_cmsg_send: if IP_PKTINFO or IPV6_PKTINFO specified
>>>>
>>>> What should I do about those? -EINVAL? Ignore the conflicting data? Leave as is?
>>>
>>> That's a good point, I guess this needs some more thought.
>>
>> I could see a point of view that says when bound_if is in play sending
>> to destinations on/via other interfaces--by any mechanism--should
>> effectively get ENETUNREACH (or something).
> 
> +1
> 
>>
>> That does seem like I would involve changing some existing behavior, though.
>>
> 
> The use of sin6_scope_id and SO_BINDTODEVICE with different interfaces
> is incorrect and should be rejected.

I agree, I would actually change the behavior at this point, as it also
could have security consequences from a network pov.

Bye,
Hannes
