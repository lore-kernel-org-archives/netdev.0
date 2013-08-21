From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ip6_tunnel: ensure to always have a link local address
Date: Wed, 21 Aug 2013 13:37:29 +0200
Message-ID: <8761uz6zra.fsf@nemi.mork.no>
References: <1376993766-5723-1-git-send-email-nicolas.dichtel@6wind.com>
	<20130820.234818.2230621827416764963.davem@davemloft.net>
	<52146EE9.1060101@6wind.com> <87haej76wz.fsf@nemi.mork.no>
	<5214958F.1080907@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33705 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459Ab3HULho convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 07:37:44 -0400
In-Reply-To: <5214958F.1080907@6wind.com> (Nicolas Dichtel's message of "Wed,
	21 Aug 2013 12:25:19 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 21/08/2013 11:02, Bj=C3=B8rn Mork a =C3=A9crit :
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>>> Le 21/08/2013 08:48, David Miller a =C3=A9crit :
>>>
>>>> Applied, but this brings up an issue I keep noticing.
>>>>
>>>> We talk about eth_random_addr() and "uniqueness" together all the
>>>> time, but the former never implies the latter.
>>>>
>>>> And we're going to run into situations where any conflicts generat=
ed
>>>> by this random address generater will cause reall failures.
>>>>
>>>> Therefore we'll have to create a system to prevent them.  Probably
>>>> using some simple table that keeps track of the addresses we've
>>>> generated.
>>>>
>>> Ok, I will look at this.
>>
>> Are eth_random_addr() collisions really any different than interface=
s
>> having the same address for other reasons?
> I would tend to say yes, it's different.
> It's easy for an administrator to fix a configuration for a physical
> interface, because it's statically configured and there is a limited
> number of interfaces.
>
> For virtual interfaces, they can be dynamically created and destroyed
> by daemons and we can have a lot of interfaces. Hence it could be har=
d
> to fix them.

If they are created by daemons then it should be up to the daemons to
fix them.  Or?

> Trying to avoid these errors at kernel level could be useful.

I strongly believe in fixing configuration issues in userspace if at al=
l
possible.  You are setting a new policy every time you implement an
automatic fix or workaround.  It is so much better to keep that out of
the kernel, or the next question you will face is "How do I change this
policy? I want the addresses to be assigned by function Y"

I see no reason why the daemon creating these interfaces can't also
fixup any collisions.  Or maybe better: If your daemon create millions
of interfaces, and cares about unique addresses, then it should
implement it's own address management.

> I've start to write a patch, and to test it I've just run a simple
> test which generate 1 000 000 of random addresses. I've run it severa=
l
> times (maybe not enough ;-)) and I never get a duplicated address...

Well, there are only 2^46 combinations so you are guaranteed to hit a
collision if you just generate 70 368 744 177 665 random addresses :-)


Bj=C3=B8rn
