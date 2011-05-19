From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: 2.6.39-rc7-git11, x86/32, failed on ppp2897'th interface,  PERCPU:  allocation failed
Date: Thu, 19 May 2011 09:47:38 +0300
Message-ID: <a8564a86400b1bd2f604767129df0dc7@visp.net.lb>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
 <1305787158.3019.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:33539 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932304Ab1ESGrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 02:47:41 -0400
In-Reply-To: <1305787158.3019.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 19 May 2011 08:39:18 +0200, Eric Dumazet wrote:
> Le jeudi 19 mai 2011 =C3=A0 09:35 +0300, Denys Fedoryshchenko a =C3=A9=
crit :
>> Hi, again
>>
>>  Just tried to upgrade large NAS from 2.6.38.6 to 2.6.39-rc7-git11,=20
>> and
>>  at same time enabling ipv6 on it.
>>  Got that, after ppp2897 brought up (sure it means there is other=20
>> 2896
>>  available, and also few ethernet vlans, around 32).
>>  I am not sure it is a bug, but it looks i had free memory(the box=20
>> had
>>  8GB free), and lowmem too, also i will try to enable there 64bit=20
>> kernel
>>  at evening.
>>
>>  May 17 16:00:42 194.146.155.70 kernel: [14925.897799] PERCPU:
>>  allocation failed, size=3D2048 align=3D4, failed to allocate new ch=
unk
>>  May 17 16:00:42 194.146.155.70 kernel: [14925.898163] Pid: 24207,=20
>> comm:
>>  pppd Not tainted 2.6.39-rc7-git11-build-0058 #4
>
> Its a known problem : When ipv6 is enabled, we allocate percpu memory=
=20
> to
> hold per device snmp counters.
>
> make sure kernel idea of max possible cpus matches real number of=20
> cpus.
>
> And yes, switching to 64bit kernel helps a lot.
>
 Yes, it matches, i guess.
 CONFIG_NR_CPUS=3D8

 processor       : 7
 vendor_id       : GenuineIntel
 cpu family      : 6
 model           : 26
 model name      : Intel(R) Core(TM) i7 CPU         950  @ 3.07GHz

 Thanks. Then i will simply switch kernel to 64bit, but for now with=20
 32bit userspace, since this semi-embedded system
 mass deployed, and i have to maintain it alone (cannot handle both=20
 32/64 bit userspace), and some pc's don't have
 lm flag in cpuinfo :)

 I am hitting a lot lowmem limits lately, but the only application that=
=20
 was not working right 32bit userspace/64bit kernel - ipvsadm.
 Should i report it as a bug (i will check if it is still an issue)?

