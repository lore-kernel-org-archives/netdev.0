From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] ip6_tunnel: ensure to always have a link local
 address
Date: Wed, 21 Aug 2013 14:11:51 +0200
Message-ID: <5214AE87.7060104@6wind.com>
References: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com> <20130820.234818.2230621827416764963.davem@davemloft.net> <52146EE9.1060101@6wind.com> <87haej76wz.fsf@nemi.mork.no> <5214958F.1080907@6wind.com> <8761uz6zra.fsf@nemi.mork.no>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:56132 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab3HUMLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 08:11:55 -0400
Received: by mail-we0-f171.google.com with SMTP id p57so190701wes.30
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 05:11:53 -0700 (PDT)
In-Reply-To: <8761uz6zra.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/08/2013 13:37, Bj=C3=B8rn Mork a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 21/08/2013 11:02, Bj=C3=B8rn Mork a =C3=A9crit :
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>>> Le 21/08/2013 08:48, David Miller a =C3=A9crit :
>>>>
>>>>> Applied, but this brings up an issue I keep noticing.
>>>>>
>>>>> We talk about eth_random_addr() and "uniqueness" together all the
>>>>> time, but the former never implies the latter.
>>>>>
>>>>> And we're going to run into situations where any conflicts genera=
ted
>>>>> by this random address generater will cause reall failures.
>>>>>
>>>>> Therefore we'll have to create a system to prevent them.  Probabl=
y
>>>>> using some simple table that keeps track of the addresses we've
>>>>> generated.
>>>>>
>>>> Ok, I will look at this.
>>>
>>> Are eth_random_addr() collisions really any different than interfac=
es
>>> having the same address for other reasons?
>> I would tend to say yes, it's different.
>> It's easy for an administrator to fix a configuration for a physical
>> interface, because it's statically configured and there is a limited
>> number of interfaces.
>>
>> For virtual interfaces, they can be dynamically created and destroye=
d
>> by daemons and we can have a lot of interfaces. Hence it could be ha=
rd
>> to fix them.
>
> If they are created by daemons then it should be up to the daemons to
> fix them.  Or?
>
>> Trying to avoid these errors at kernel level could be useful.
>
> I strongly believe in fixing configuration issues in userspace if at =
all
> possible.  You are setting a new policy every time you implement an
> automatic fix or workaround.  It is so much better to keep that out o=
f
> the kernel, or the next question you will face is "How do I change th=
is
> policy? I want the addresses to be assigned by function Y"
>
> I see no reason why the daemon creating these interfaces can't also
> fixup any collisions.  Or maybe better: If your daemon create million=
s
> of interfaces, and cares about unique addresses, then it should
> implement it's own address management.
Ok ok, you convince me ;-)

I will wait David feedback.

>
>> I've start to write a patch, and to test it I've just run a simple
>> test which generate 1 000 000 of random addresses. I've run it sever=
al
>> times (maybe not enough ;-)) and I never get a duplicated address...
>
> Well, there are only 2^46 combinations so you are guaranteed to hit a
> collision if you just generate 70 368 744 177 665 random addresses :-=
)
Yes, it was just to say that the function which generate these addresse=
s has a=20
"good" entropy ;-)
