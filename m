From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Subject: RE: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 11:06:07 +0000
Message-ID: <8A42379416420646B9BFAC9682273B6D0EDD9A3C@limkexm3.ad.analog.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>	<4B20BB36.50509@grandegger.com>	<8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com><4B20CB82.6060702@grandegger.com> <4B20D214.4050503@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, "H.J. Oertel" <oe@port.de>,
	<uclinux-dist-devel@blackfin.uclinux.org>
To: "Wolfgang Grandegger" <wg@grandegger.com>,
	"Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:23747 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985AbZLJLGF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 06:06:05 -0500
Content-Class: urn:content-classes:message
In-Reply-To: <4B20D214.4050503@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>Wolfgang Grandegger wrote:
>> Mike Frysinger wrote:
>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>> Barry Song wrote:
>>>>> +#include <linux/module.h>
>>>>> +#include <linux/init.h>
>>>>> +#include <linux/kernel.h>
>>>>> +#include <linux/types.h>
>>>> I think you don't need "types.h" as the code no longer uses
>"uint*_t".
>>> linux/types.h declares all types, like u* which this driver still
>uses
>>
>> I just remember that "linux/types.h" needs to be added for the
uint*_t
>> types. At a first glance I do not see __u8/u8 being defined in that
>> header file but I might have missed something.
>>
>>>> Well, I'm still not a friend of the following inline functions,
>>>> especially the *one-liners* which are called just *once*. With the
>usage
>>>> of structs they seem even more useless.
>>> seems like it would make more sense to not even use the read/write
>>> functions either.  just declare the regs as volatile and assign/read
>>> the struct directly.
>>
>> Two times no. Don't use volatile and proper accessor functions. See:
>>
>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-
>harmful.txt
>
>I was just wondering if bfin_read/write16 would not be the proper
>accessor functions. readw/writew seems to be implemented differently:
>
>http://lxr.linux.no/#linux+v2.6.32/arch/blackfin/include/asm/io.h#L44
>
>Puh, they do an cli,nop,nop,sync..sti for the access. This also nicely
>shows why accessor functions should be used to access device registers.
>
>Well, just curious. I don't really know the blackfin arch.

Well - on Blackfin its absolutely ok to access System Memory Mapped
Registers using structs.
At any rate volatile is then required to prevent the compiler to
optimize accesses away.
IMHO this is a pretty legal use of volatile, and used in hundreds of
places all over the kernel. 
 
When accessing external controllers accessor functions from io.h must be
used.
There are two things to consider here:
1) weak ordering of reads and writes 
2) killed and reissued reads (especially harmful when reading from
FIFOs)

-Michael

>
>Wolfgang.
>
>_______________________________________________
>Uclinux-dist-devel mailing list
>Uclinux-dist-devel@blackfin.uclinux.org
>https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel
