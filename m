From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Wed, 10 Aug 2016 07:44:18 +0900
Message-ID: <ed271d49-e796-ebaa-2e71-35711710fd49@miraclelinux.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net>
 <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net>
 <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
 <04a393c9-39f8-8d73-3476-928732e5b193@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Ahern <dsa@cumulusnetworks.com>, Erik Kline <ek@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33051 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932461AbcHIWoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 18:44:22 -0400
Received: by mail-pa0-f48.google.com with SMTP id ti13so9251331pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 15:44:22 -0700 (PDT)
In-Reply-To: <04a393c9-39f8-8d73-3476-928732e5b193@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Ahern wrote:
> On 8/9/16 1:01 AM, Erik Kline wrote:
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
> VRF uses this capability to send on an enslaved interface. ie., socket is bound to VRF device to limit packets to that L3 domain and then uses PKTINFO to force a packet out a particular interface.
> 

We could extend our code to allow enslave devices, maybe.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
