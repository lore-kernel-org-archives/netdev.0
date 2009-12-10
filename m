From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 05:58:58 -0500
Message-ID: <8bd0f97a0912100258n6896b21er1d9525bb7dbf6aec@mail.gmail.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com> <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
	<4B20CB82.6060702@grandegger.com> <4B20D214.4050503@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:55333 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933556AbZLJK7M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:59:12 -0500
Received: by yxe17 with SMTP id 17so6805479yxe.33
        for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 02:59:18 -0800 (PST)
In-Reply-To: <4B20D214.4050503@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 10, 2009 at 05:48, Wolfgang Grandegger wrote:
> Wolfgang Grandegger wrote:
>> Mike Frysinger wrote:
>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>> Well, I'm still not a friend of the following inline functions,
>>>> especially the *one-liners* which are called just *once*. With the=
 usage
>>>> of structs they seem even more useless.
>>> seems like it would make more sense to not even use the read/write
>>> functions either. =C2=A0just declare the regs as volatile and assig=
n/read
>>> the struct directly.
>>
>> Two times no. Don't use volatile and proper accessor functions. See:
>>
>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered=
-harmful.txt
>
> I was just wondering if bfin_read/write16 would not be the proper
> accessor functions. readw/writew seems to be implemented differently:
>
> http://lxr.linux.no/#linux+v2.6.32/arch/blackfin/include/asm/io.h#L44
>
> Puh, they do an cli,nop,nop,sync..sti for the access. This also nicel=
y
> shows why accessor functions should be used to access device register=
s.
>
> Well, just curious. I don't really know the blackfin arch.

the common I/O functions need to account for issues surrounding the
bus that has arbitrary devices memory mapped to it.  on-chip devices
(like what we're talking about here) do not have these issues and so
using the common functions is awful overhead.
-mike
