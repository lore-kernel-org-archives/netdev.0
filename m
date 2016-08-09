From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Tue, 9 Aug 2016 16:01:04 +0900
Message-ID: <CAAedzxq-XYTVgZ7=VX-OWHYNSRjDuf==si-my=Jy3YEo7atcWQ@mail.gmail.com>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
 <20160808.143500.473355495580691289.davem@davemloft.net> <CAKD1Yr25UUNOANnUD+cCszA2HfoPrsEPxaGqgqBBBG_wcs1tGg@mail.gmail.com>
 <20160808.222030.1314134961786852070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36363 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbcHIHB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 03:01:27 -0400
Received: by mail-wm0-f46.google.com with SMTP id q128so14752960wma.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 00:01:26 -0700 (PDT)
In-Reply-To: <20160808.222030.1314134961786852070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 August 2016 at 14:20, David Miller <davem@davemloft.net> wrote:
> From: Lorenzo Colitti <lorenzo@google.com>
> Date: Tue, 9 Aug 2016 10:00:25 +0900
>
>> Note that pretty much every sendmsg codepath allows other data to take
>> precedence over sk_bound_dev_if:
>>
>> - udpv6_sendmsg: if sin6_scope_id specified on a scoped address
>> - rawv6_sendmsg: if sin6_scope_id specified on a scoped address
>> - l2tp_ip6_sendmsg: if sin6_scope_id specified on a scoped address
>> - ip_cmsg_send: if IP_PKTINFO or IPV6_PKTINFO specified
>>
>> What should I do about those? -EINVAL? Ignore the conflicting data? Leave as is?
>
> That's a good point, I guess this needs some more thought.

I could see a point of view that says when bound_if is in play sending
to destinations on/via other interfaces--by any mechanism--should
effectively get ENETUNREACH (or something).

That does seem like I would involve changing some existing behavior, though.
