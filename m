From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 21:17:36 -0500
Message-ID: <8bd0f97a0912101817x79a17d5dje21e2a2b4ad1fc58@mail.gmail.com>
References: <4B20CB82.6060702@grandegger.com> <4B20D214.4050503@grandegger.com>
	<8bd0f97a0912100258n6896b21er1d9525bb7dbf6aec@mail.gmail.com>
	<20091210.133729.42872813.davem@davemloft.net> <3c17e3570912101805n682c316l44ec68ade5d18cd1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, wg@grandegger.com, oe@port.de,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org
To: Barry Song <21cnbao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:46286 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761250AbZLKCRt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 21:17:49 -0500
Received: by gxk4 with SMTP id 4so619676gxk.8
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 18:17:56 -0800 (PST)
In-Reply-To: <3c17e3570912101805n682c316l44ec68ade5d18cd1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 21:05, Barry Song wrote:
> 2009/12/11 David Miller <davem@davemloft.net>:
>> From: Mike Frysinger <vapier.adi@gmail.com>
>>> On Thu, Dec 10, 2009 at 05:48, Wolfgang Grandegger wrote:
>>>> Wolfgang Grandegger wrote:
>>>>> Mike Frysinger wrote:
>>>>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>>>>> Well, I'm still not a friend of the following inline functions,
>>>>>>> especially the *one-liners* which are called just *once*. With =
the usage
>>>>>>> of structs they seem even more useless.
>>>>>> seems like it would make more sense to not even use the read/wri=
te
>>>>>> functions either. =EF=BF=BD,A just declare the regs as volatile =
and assign/read
>>>>>> the struct directly.
>>>>>
>>>>> Two times no. Don't use volatile and proper accessor functions. S=
ee:
>>>>>
>>>>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-conside=
red-harmful.txt
>>>>
>>>> I was just wondering if bfin_read/write16 would not be the proper
>>>> accessor functions. readw/writew seems to be implemented different=
ly:
>>>>
>>>> http://lxr.linux.no/#linux+v2.6.32/arch/blackfin/include/asm/io.h#=
L44
>>>>
>>>> Puh, they do an cli,nop,nop,sync..sti for the access. This also ni=
cely
>>>> shows why accessor functions should be used to access device regis=
ters.
>>>>
>>>> Well, just curious. I don't really know the blackfin arch.
>>>
>>> the common I/O functions need to account for issues surrounding the
>>> bus that has arbitrary devices memory mapped to it. =C2=A0on-chip d=
evices
>>> (like what we're talking about here) do not have these issues and s=
o
>>> using the common functions is awful overhead.
>>
>> Then create special accessors (perhaps with the same names as the
>> existing ones, but with "__" prepended) that lack all of the
>> interrupt disabling, syncs, etc.
>>
>> Really it _is_ cleaner and makes your driver look a lot nicer.
>
> I think Mike has said the functions are bfin_read/bfin_write in
> blackfin arch since those CAN registers are located in memory mapped
> area but not async memory and have less overhead than common io
> functions? Is it acceptable to use those functions in this driver?

yes, bfin_{read,write} should be used
-mike
