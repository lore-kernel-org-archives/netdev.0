From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH 1/3] net: bgmac: allocate struct bgmac just once & don't
 copy it
Date: Fri, 27 Jan 2017 17:24:38 +0100
Message-ID: <CACna6rxuz6Ci=t5D1OGdPw4L0rLuLz6Lp7XrsviMS8C+upR=CQ@mail.gmail.com>
References: <20170127092043.17413-1-zajec5@gmail.com> <20170127092043.17413-2-zajec5@gmail.com>
 <8bb6614b-a4af-d435-7db8-616cb1c1a56d@nbd.name> <20170127.111450.1252941253517746124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Felix Fietkau <nbd@nbd.name>, Jon Mason <jon.mason@broadcom.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felix Fietkau <nbd@openwrt.org>,
        Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33105 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751423AbdA0UIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:08:55 -0500
Received: by mail-oi0-f68.google.com with SMTP id j15so21432206oih.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:08:55 -0800 (PST)
In-Reply-To: <20170127.111450.1252941253517746124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27 January 2017 at 17:14, David Miller <davem@davemloft.net> wrote:
> From: Felix Fietkau <nbd@nbd.name>
> Date: Fri, 27 Jan 2017 17:02:33 +0100
>
>> On 2017-01-27 10:20, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> From: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>>>
>>> To share as much code as possible in bgmac we call alloc_etherdev from
>>> bgmac.c which is used by both: platform and bcma code. The easiest
>>> solution was to use it for allocating whole struct bgmac but it doesn't
>>> work well as we already get early-filled struct bgmac as an argument.
>>>
>>> So far we were solving this by copying received struct into newly
>>> allocated one. The problem is it means storing 2 allocated structs,
>>> using only 1 of them and non-shared code not having access to it.
>>>
>>> This patch solves it by using alloc_etherdev to allocate *pointer* for
>>> the already allocated struct. The only downside of this is we have to b=
e
>>> careful when using netdev_priv.
>>>
>>> Another solution was to call alloc_etherdev in platform/bcma specific
>>> code but Jon advised against it due to sharing less code that way.
>> How does that lead to sharing less code?
>> I find this pointer indirection rather ugly and uncommon, and I think it
>> would be much cleaner to split the probe into bgmac_enet_alloc and
>> bgmac_enet_probe (with bgmac_enet_alloc calling alloc_etherdev and doing
>> basic setup).
>
> I agree, it would be so much better if bgmac_probe() and friends
> initialized a real bgmac object which was the private of a netdev
> struct, then passed that down into bgmac_enet_probe().

I'll work on V2, thanks.

--=20
Rafa=C5=82
