From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog
 Devices Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 13:37:29 -0800 (PST)
Message-ID: <20091210.133729.42872813.davem@davemloft.net>
References: <4B20CB82.6060702@grandegger.com>
	<4B20D214.4050503@grandegger.com>
	<8bd0f97a0912100258n6896b21er1d9525bb7dbf6aec@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, oe@port.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44204
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755669AbZLJVhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:37:22 -0500
In-Reply-To: <8bd0f97a0912100258n6896b21er1d9525bb7dbf6aec@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Thu, 10 Dec 2009 05:58:58 -0500

> On Thu, Dec 10, 2009 at 05:48, Wolfgang Grandegger wrote:
>> Wolfgang Grandegger wrote:
>>> Mike Frysinger wrote:
>>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>>> Well, I'm still not a friend of the following inline functions,
>>>>> especially the *one-liners* which are called just *once*. With the usage
>>>>> of structs they seem even more useless.
>>>> seems like it would make more sense to not even use the read/write
>>>> functions either. ,A (Bjust declare the regs as volatile and assign/read
>>>> the struct directly.
>>>
>>> Two times no. Don't use volatile and proper accessor functions. See:
>>>
>>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-harmful.txt
>>
>> I was just wondering if bfin_read/write16 would not be the proper
>> accessor functions. readw/writew seems to be implemented differently:
>>
>> http://lxr.linux.no/#linux+v2.6.32/arch/blackfin/include/asm/io.h#L44
>>
>> Puh, they do an cli,nop,nop,sync..sti for the access. This also nicely
>> shows why accessor functions should be used to access device registers.
>>
>> Well, just curious. I don't really know the blackfin arch.
> 
> the common I/O functions need to account for issues surrounding the
> bus that has arbitrary devices memory mapped to it.  on-chip devices
> (like what we're talking about here) do not have these issues and so
> using the common functions is awful overhead.

Then create special accessors (perhaps with the same names as the
existing ones, but with "__" prepended) that lack all of the
interrupt disabling, syncs, etc.

Really it _is_ cleaner and makes your driver look a lot nicer.
