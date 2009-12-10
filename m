From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
 	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 12:16:17 +0100
Message-ID: <4B20D881.3090003@grandegger.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com> 	<4B20BB36.50509@grandegger.com> <8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com> 	<4B20CB82.6060702@grandegger.com> <8bd0f97a0912100245k9930c90ke4b184da68a9f958@mail.gmail.com> 	<4B20D39C.6030103@grandegger.com> <8bd0f97a0912100304p16087688q681710ba6b152c0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Barry Song <21cnbao@gmail.com>, socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, davem@davemloft.net,
	"H.J. Oertel" <oe@port.de>, netdev@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:39625 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760631AbZLJLQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 06:16:57 -0500
In-Reply-To: <8bd0f97a0912100304p16087688q681710ba6b152c0c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
> On Thu, Dec 10, 2009 at 05:55, Wolfgang Grandegger wrote:
>> Mike Frysinger wrote:
>>> On Thu, Dec 10, 2009 at 05:20, Wolfgang Grandegger wrote:
>>>> Mike Frysinger wrote:
>>>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>>>> Barry Song wrote:
>>>>>>> +#include <linux/module.h>
>>>>>>> +#include <linux/init.h>
>>>>>>> +#include <linux/kernel.h>
>>>>>>> +#include <linux/types.h>
>>>>>> I think you don't need "types.h" as the code no longer uses "uint*_t".
>>>>> linux/types.h declares all types, like u* which this driver still uses
>>>> I just remember that "linux/types.h" needs to be added for the uint*_t
>>>> types. At a first glance I do not see __u8/u8 being defined in that
>>>> header file but I might have missed something.
>>> you need to follow the include paths
>> I thought I did. Could you point me to the relevant location?
> 
> make kernel/printk.i
> sed -n -e '/^#/p' -e '/ u64;/{p;q}' kernel/printk.i
> linux/types.h -> asm/types.h -> asm-generic/types.h -> asm-generic/int-ll64.h

Thanks.

>>>>>> Well, I'm still not a friend of the following inline functions,
>>>>>> especially the *one-liners* which are called just *once*. With the usage
>>>>>> of structs they seem even more useless.
>>>>> seems like it would make more sense to not even use the read/write
>>>>> functions either.  just declare the regs as volatile and assign/read
>>>>> the struct directly.
>>>> Two times no. Don't use volatile and proper accessor functions. See:
>>>>
>>>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-harmful.txt
>>> too bad the document is largely irrelevant (all but one paragraph)
>>> because this is how volatiles were designed in the first place --
>>> hardware I/O registers.  the CAN implementation here is Blackfin
>>> specific and not going to be use elsewhere, so other architectures are
>>> irrelevant.  the resulting C code would certainly look a hell of a lot
>>> more natural without the useless I/O accessor functions, and be much
>>> tighter.
>> Well, so far *no* volatiles have been used in the BFIN CAN driver. But
>> if you tell me that they are really required for blackfin... I can't
>> really judge.
> 
> i'm not saying they're needed all the time, i'm saying volatile
> produces more natural coding style than I/O accessors.  but after
> reviewing the bfin_read/bfin_write functions, we still need to use
> those to workaround a simple anomaly on older parts.

I believe that it's good practice to hide such details by using proper
accessor functions.

Wolfgang.
