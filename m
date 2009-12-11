From: Barry Song <21cnbao@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Fri, 11 Dec 2009 10:05:06 +0800
Message-ID: <3c17e3570912101805n682c316l44ec68ade5d18cd1@mail.gmail.com>
References: <4B20CB82.6060702@grandegger.com> <4B20D214.4050503@grandegger.com>
	<8bd0f97a0912100258n6896b21er1d9525bb7dbf6aec@mail.gmail.com>
	<20091210.133729.42872813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vapier.adi@gmail.com, wg@grandegger.com, oe@port.de,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.211.176]:36294 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762184AbZLKCFV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 21:05:21 -0500
Received: by ywh6 with SMTP id 6so451572ywh.4
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 18:05:27 -0800 (PST)
In-Reply-To: <20091210.133729.42872813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/12/11 David Miller <davem@davemloft.net>:
> From: Mike Frysinger <vapier.adi@gmail.com>
> Date: Thu, 10 Dec 2009 05:58:58 -0500
>
>> On Thu, Dec 10, 2009 at 05:48, Wolfgang Grandegger wrote:
>>> Wolfgang Grandegger wrote:
>>>> Mike Frysinger wrote:
>>>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>>>> Well, I'm still not a friend of the following inline functions,
>>>>>> especially the *one-liners* which are called just *once*. With t=
he usage
>>>>>> of structs they seem even more useless.
>>>>> seems like it would make more sense to not even use the read/writ=
e
>>>>> functions either. =EF=BF=BD,A just declare the regs as volatile a=
nd assign/read
>>>>> the struct directly.
>>>>
>>>> Two times no. Don't use volatile and proper accessor functions. Se=
e:
>>>>
>>>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-consider=
ed-harmful.txt
>>>
>>> I was just wondering if bfin_read/write16 would not be the proper
>>> accessor functions. readw/writew seems to be implemented differentl=
y:
>>>
>>> http://lxr.linux.no/#linux+v2.6.32/arch/blackfin/include/asm/io.h#L=
44
>>>
>>> Puh, they do an cli,nop,nop,sync..sti for the access. This also nic=
ely
>>> shows why accessor functions should be used to access device regist=
ers.
>>>
>>> Well, just curious. I don't really know the blackfin arch.
>>
>> the common I/O functions need to account for issues surrounding the
>> bus that has arbitrary devices memory mapped to it. =C2=A0on-chip de=
vices
>> (like what we're talking about here) do not have these issues and so
>> using the common functions is awful overhead.
>
> Then create special accessors (perhaps with the same names as the
> existing ones, but with "__" prepended) that lack all of the
> interrupt disabling, syncs, etc.
>
> Really it _is_ cleaner and makes your driver look a lot nicer.

I think Mike has said the functions are bfin_read/bfin_write in
blackfin arch since those CAN registers are located in memory mapped
area but not async memory and have less overhead than common io
functions? Is it acceptable to use those functions in this driver?

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml
>
