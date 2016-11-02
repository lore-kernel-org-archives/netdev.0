From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2] ipv4: fib: Replay events when registering
 FIB notifier
Date: Wed, 2 Nov 2016 14:48:45 +0100
Message-ID: <20161102134845.GI1713@nanopsycho.orion>
References: <1477948427-9189-1-git-send-email-idosch@idosch.org>
 <1477949046.7065.320.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161031225737.7nfoy4ka3ydzhptq@splinter>
 <1478009999.7065.334.camel@edumazet-glaptop3.roam.corp.google.com>
 <5818B146.20209@cumulusnetworks.com>
 <20161101170345.pq2ewecw35mrurkp@splinter>
 <58194BD6.5040406@cumulusnetworks.com>
 <20161102072032.GA1713@nanopsycho.orion>
 <CAJieiUjGHX0C7mG3Y8m2VZHPPq=Rz-2D8e_L9ZASi-bCs8nJJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@idosch.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, mlxsw <mlxsw@mellanox.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        alexander.h.duyck@intel.com,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Ido Schimmel <idosch@mellanox.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35691 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754259AbcKBNss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 09:48:48 -0400
Received: by mail-wm0-f65.google.com with SMTP id 68so3174827wmz.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 06:48:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJieiUjGHX0C7mG3Y8m2VZHPPq=Rz-2D8e_L9ZASi-bCs8nJJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Nov 02, 2016 at 02:29:40PM CET, roopa@cumulusnetworks.com wrote:
>On Wed, Nov 2, 2016 at 12:20 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Nov 02, 2016 at 03:13:42AM CET, roopa@cumulusnetworks.com wrote:
>>>
>[snip]
>
>>>I understand..but, if you are adding some core infrastructure for switchdev ..it cannot be
>>>based on the number of simple use-cases or data you have today.
>>>
>>>I won't be surprised if tomorrow other switch drivers have a case where they need to
>>>reset the hw routing table state and reprogram all routes again. Re-registering the notifier to just
>>>get the routing state of the kernel will not scale. For the long term, since the driver does not maintain a cache,
>>
>> Driver (mlxsw, rocker) maintain a cache. So I'm not sure why you say
>> otherwise.
>>
>>
>>>a pull api with efficient use of rtnl will be useful for other such cases as well.
>>
>> How do you imagine this "pull API" should look like?
>
>
>Just like you already have added fib notifiers to parallel fib netlink
>notifications, the pull API is  a parallel to 'netlink dump'.
>Is my imagination too wild  ? :)

Perhaps I'm slow, but I don't understand what you mean.


>
>
>>
>>
>>>
>>>
>>>If you don't want to get to the complexity of a new api right away because of the
>>>simple case of management interface routes you have, Can your driver register the notifier early  ?
>>>(I am sure you have probably already thought about this)
>>
>> Register early? What it would resolve? I must be missing something. We
>> register as early as possible. But the thing is, we cannot register
>> in a past. And that is what this patch resolves.
>
>sure, you must be having a valid problem then. I was just curious why
>your driver is not up and initialized before any of the addresses or
>routes get configured in the system (even on a management port). Ours

If you unload the module and load it again for example. This is a valid
usecase.


>does. But i agree there can be races and you cannot always guarantee
>(I was just responding to ido's comment about adding complexity for a
>small problem he has to solve for management routes). Our driver does
>a pull before it starts. This helps when we want to reset the hardware
>routing table state too.

Can you point me to you driver in the tree? I would like to see how you
do "the pull".


>
>
>But, my point was, when you are defining an API, you cannot quantify
>the 'past' to be just the very 'close past' or 'the past is just the
>management routes that were added' . Tomorrow the 'past' can be the
>full routing table if you need to reset the hardware state.

Sure.
