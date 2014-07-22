From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 22 Jul 2014 18:12:39 +0800
Message-ID: <CAJxxZ0NBQk3324eXzhKJebPjD=7uUsxOm9x26NeEMMMe=ZYzMA@mail.gmail.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	<1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140722.010105.2036198226851589509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:45936 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754242AbaGVKMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:12:39 -0400
Received: by mail-oa0-f50.google.com with SMTP id g18so9410488oah.9
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:12:39 -0700 (PDT)
In-Reply-To: <20140722.010105.2036198226851589509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Jul 22, 2014 at 4:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Jul 2014 09:59:44 +0200
>
>> On Tue, 2014-07-22 at 15:38 +0800, Sonic Zhang wrote:
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>>> +    if (i < budget) {
>>> +            napi_complete(napi);
>>> +            if (lp->rx_irq_disabled--)
>>> +                    if (!lp->rx_irq_disabled)
>>> +                            enable_irq(IRQ_MAC_RX);
>>
>>
>> You wrote :
>>
>>       if (A--)
>>               if (!A)
>>                       something();
>>
>> Isnt a bit strange ???
>
> Indeed, it's very strange, how about:
>
>         if (!--lp->rx_irq_disabled)
>
> which is the canonical way to express this.

I made a mistake on the condition logic. Is following logic fine to you?

            if (lp->rx_irq_disabled > 0 && !--lp->rx_irq_disabled)
                            enable_irq(IRQ_MAC_RX);


Thanks,

Sonic Zhang
