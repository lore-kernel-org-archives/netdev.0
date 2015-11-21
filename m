From: Andrew <nitr0@seti.kr.ua>
Subject: Re: Kernel 4.1.12 crash
Date: Sat, 21 Nov 2015 10:16:59 +0200
Message-ID: <5650287B.9070901@seti.kr.ua>
References: <564F26FF.3040605@seti.kr.ua> <564FA904.7020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pop3.seti.kr.ua ([91.202.132.4]:56572 "EHLO mail.seti.kr.ua"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752130AbbKUIRG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Nov 2015 03:17:06 -0500
Received: from [91.202.135.100] (helo=[192.168.0.145])
	by mail.seti.kr.ua with esmtpa (Exim 4.68)
	(envelope-from <nitr0@seti.kr.ua>)
	id 1a03Lv-0007DQ-L6
	for netdev@vger.kernel.org; Sat, 21 Nov 2015 10:17:02 +0200
In-Reply-To: <564FA904.7020603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory corruption, if happens, IMHO shouldn't be a hardware-related -=20
almost all of these boxes, except H61M-based box from 1st log, works fo=
r=20
a long time with uptime more than year; and only software was changed o=
n=20
it; H61M-based box runs memtest86 for a tens of hours w/o any error. If=
=20
it was caused by hardware - they should crash even earlier.

Rarely on different servers I saw 'zram decompression error' messages=20
(in this case I've got such message on H61M-based box).

Also, other people that uses accel-ppp as BRAS software, have different=
=20
kernel panics/bugs/oopses on fresh kernels.

I'll try to apply these patches, and I'll try to switch back to kernels=
=20
that were stable on some boxes.

21.11.2015 01:13, Alexander Duyck =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 11/20/2015 05:58 AM, Andrew wrote:
>> Hi all.
>>
>> Today some BRASes on 4.1.12 kernel were crashed.
>>
>> Here's crash traces: http://pastebin.com/p68hNS8R
>> http://pastebin.com/36ieRAM2 http://pastebin.com/3BRTVEB6
>>
>> On 3.2 kernel same hardware works OK, troubles were noticed after ke=
rnel
>> upgrade.
>>
>> What additional info is needed?
>
> Looking over the traces there seem to be two areas called out.
>
> The first is the fib_trie resize BUG_ON that was triggered due to the=
=20
> parent and child not being associated.  I think that might be due to=20
> memory corruption as I cannot find any spots where we are resizing=20
> without correctly setting up the parent-child relationship of the=20
> nodes first.
>
> The other spot that is showing up is ppp_shutdown_interface and it's=20
> related path.  It looks like there are a couple of patches you could=20
> try back-porting to see if it resolves the issue.  If they do then=20
> perhaps they should be considered candidates for stable:
>
> 8cb775bc0a3 ("ppp: fix device unregistration upon netns deletion")
> 58a89ecaca5 ("ppp: fix lockdep splat in ppp_dev_uninit()")
>
> - Alex
