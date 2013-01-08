From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V5] bgmac: driver for GBit MAC core on BCMA bus
Date: Tue, 8 Jan 2013 12:03:23 +0100
Message-ID: <CACna6rxEOfAPsZDn=zrcE2eAocdX4C4QxpdtDjJ+JCMLCAQqUw@mail.gmail.com>
References: <1357626888-2375-1-git-send-email-zajec5@gmail.com>
	<50EBE8EE.2030902@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Joe Perches <joe@perches.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:34650 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab3AHLDY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 06:03:24 -0500
Received: by mail-we0-f179.google.com with SMTP id r6so212395wey.38
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 03:03:23 -0800 (PST)
In-Reply-To: <50EBE8EE.2030902@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/8 Florian Fainelli <florian@openwrt.org>:
> Hello Rafal,
>
> Le 01/08/13 07:34, Rafa=C5=82 Mi=C5=82ecki a =C3=A9crit :
>
>> BCMA is a Broadcom specific bus with devices AKA cores. All recent B=
CMA
>> based SoCs have gigabit ethernet provided by the GBit MAC core. This
>> patch adds driver for such a cores registering itself as a netdev. I=
t
>> has been tested on a BCM4706 and BCM4718 chipsets.
>>
>> In the kernel tree there is already b44 driver which has some common
>> things with bgmac, however there are many differences that has led t=
o
>> the decision or writing a new driver:
>> 1) GBit MAC cores appear on BCMA bus (not SSB as in case of b44)
>> 2) There is 64bit DMA engine which differs from 32bit one
>> 3) There is no CAM (Content Addressable Memory) in GBit MAC
>> 4) We have 4 TX queues on GBit MAC devices (instead of 1)
>> 5) Many registers have different addresses/values
>> 6) RX header flags are also different
>>
>> The driver in it's state is functional how, however there is of cour=
se
>> place for improvements:
>> 1) Supporting more net_device_ops
>> 2) SUpporting more ethtool_ops
>> 3) Unaligned addressing in DMA
>> 4) Writing separated PHY driver
>
>
> It does not seem like 4) would be too hard to do just right now becau=
se your
> PHY functions actually match the semantics of the callbacks you are s=
upposed
> to implement for a separate PHY driver. Doing this would make you use=
 phylib
> in the bgmac driver which is a good thing.
>
> I would be glad if you could do this just now, so we make sure this d=
oes not
> get lost.
>
> If David is ok with your v5 patch and wants to merge it just now, I a=
m just
> as happy with that.

Personally I'd like to have it pushed even with limited features, as
long as it doesn't go anything really wrong.

It's harder to maintain whole driver as a patch, harder to make a
changes, harder to track/review them and somehow discouraging the
developer (me). I prefer sending small changes than mini-bomb of 64KB
code each time I want to change 5 lines.
You can always find some small feature that could be implemented with
a low cost and postpone driver inclusion for weeks/months. I'd like to
avoid that.
Apart from that, having driver pushed into some "real" tree makes it
possible for other developers to cooperate (see Nathan who sent fixes
to OpenWRT).

If you're afraid of forgetting anything from the "TODO" list placed in
commit message, we can always create a "TODO" file for the driver. I
don't think we really need that though.

--=20
Rafa=C5=82
