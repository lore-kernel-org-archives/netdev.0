From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,  PERCPU:  allocation failed
Date: Thu, 19 May 2011 10:28:26 +0300
Message-ID: <10f61af229a48d77d06d154b4647cdde@visp.net.lb>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
 <1305787158.3019.12.camel@edumazet-laptop>
 <1305788113.3019.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:45257 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756054Ab1ESH22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:28:28 -0400
In-Reply-To: <1305788113.3019.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 19 May 2011 08:55:13 +0200, Eric Dumazet wrote:
> Le jeudi 19 mai 2011 =C3=A0 08:39 +0200, Eric Dumazet a =C3=A9crit :
>
>> Its a known problem : When ipv6 is enabled, we allocate percpu=20
>> memory to
>> hold per device snmp counters.
>>
>> make sure kernel idea of max possible cpus matches real number of=20
>> cpus.
>>
>> And yes, switching to 64bit kernel helps a lot.
>>
>>
>
> Looking at snmp6_alloc_dev(), we allocate three mib per device :
>
> ipstats_mib  (30 * sizeof(u64) * number_of_possible_cpus)
> icmpv6_mib    (4 * sizeof(long) * number_of_possible_cpus)
> icmpv6msg_mib  (26 * sizeof(long))
 1920 +
 256 +
 208 =3D 2386 * 3000ppp's =3D 7152000, i think it is not that much at a=
ny=20
 case, if i am not wrong.

 But at any case i will try 64bit.

>
> For sure icmp ones dont need percpu counter. Plain atomic_long_t
> (shared) would be enough, since ICMP messages are rare enough.


