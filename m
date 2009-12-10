From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 12:19:48 +0100
Message-ID: <4B20D954.8040002@grandegger.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>	<4B20BB36.50509@grandegger.com>	<8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com><4B20CB82.6060702@grandegger.com>
	<4B20D214.4050503@grandegger.com>
	<8A42379416420646B9BFAC9682273B6D0EDD9A3C@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "H.J. Oertel" <oe-pJ9TYRvN+WE@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "Hennerich, Michael" <Michael.Hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8A42379416420646B9BFAC9682273B6D0EDD9A3C-pcKY8lWzTjquVPpjEGsWsTcYPEmu4y7e@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hennerich, Michael wrote:
> 
>> Wolfgang Grandegger wrote:
>>> Mike Frysinger wrote:
>>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>>> Barry Song wrote:
>>>>>> +#include <linux/module.h>
>>>>>> +#include <linux/init.h>
>>>>>> +#include <linux/kernel.h>
>>>>>> +#include <linux/types.h>
>>>>> I think you don't need "types.h" as the code no longer uses
>> "uint*_t".
>>>> linux/types.h declares all types, like u* which this driver still
>> uses
>>> I just remember that "linux/types.h" needs to be added for the
> uint*_t
>>> types. At a first glance I do not see __u8/u8 being defined in that
>>> header file but I might have missed something.
>>>
>>>>> Well, I'm still not a friend of the following inline functions,
>>>>> especially the *one-liners* which are called just *once*. With the
>> usage
>>>>> of structs they seem even more useless.
>>>> seems like it would make more sense to not even use the read/write
>>>> functions either.  just declare the regs as volatile and assign/read
>>>> the struct directly.
>>> Two times no. Don't use volatile and proper accessor functions. See:
>>>
>>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-
>> harmful.txt
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
> Well - on Blackfin its absolutely ok to access System Memory Mapped
> Registers using structs.
> At any rate volatile is then required to prevent the compiler to
> optimize accesses away.
> IMHO this is a pretty legal use of volatile, and used in hundreds of
> places all over the kernel. 
>  
> When accessing external controllers accessor functions from io.h must be
> used.
> There are two things to consider here:
> 1) weak ordering of reads and writes 
> 2) killed and reissued reads (especially harmful when reading from
> FIFOs)

OK, anyway, I believe that it's good practice to hide all such details
by using proper accessor functions.

Wolfgang.
