From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog Devices
	Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 11:55:24 +0100
Message-ID: <4B20D39C.6030103@grandegger.com>
References: <1260430072-21106-1-git-send-email-21cnbao@gmail.com>
	<4B20BB36.50509@grandegger.com>
	<8bd0f97a0912100204gd2b09f6r2799d9f951d6b9e1@mail.gmail.com>
	<4B20CB82.6060702@grandegger.com>
	<8bd0f97a0912100245k9930c90ke4b184da68a9f958@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "H.J. Oertel" <oe-pJ9TYRvN+WE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <8bd0f97a0912100245k9930c90ke4b184da68a9f958-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

Mike Frysinger wrote:
> On Thu, Dec 10, 2009 at 05:20, Wolfgang Grandegger wrote:
>> Mike Frysinger wrote:
>>> On Thu, Dec 10, 2009 at 04:11, Wolfgang Grandegger wrote:
>>>> Barry Song wrote:
>>>>> +#include <linux/module.h>
>>>>> +#include <linux/init.h>
>>>>> +#include <linux/kernel.h>
>>>>> +#include <linux/types.h>
>>>> I think you don't need "types.h" as the code no longer uses "uint*_t".
>>> linux/types.h declares all types, like u* which this driver still uses
>> I just remember that "linux/types.h" needs to be added for the uint*_t
>> types. At a first glance I do not see __u8/u8 being defined in that
>> header file but I might have missed something.
> 
> you need to follow the include paths

I thought I did. Could you point me to the relevant location?

>>>> Well, I'm still not a friend of the following inline functions,
>>>> especially the *one-liners* which are called just *once*. With the usage
>>>> of structs they seem even more useless.
>>> seems like it would make more sense to not even use the read/write
>>> functions either.  just declare the regs as volatile and assign/read
>>> the struct directly.
>> Two times no. Don't use volatile and proper accessor functions. See:
>>
>> http://lxr.linux.no/#linux+v2.6.32/Documentation/volatile-considered-harmful.txt
> 
> too bad the document is largely irrelevant (all but one paragraph)
> because this is how volatiles were designed in the first place --
> hardware I/O registers.  the CAN implementation here is Blackfin
> specific and not going to be use elsewhere, so other architectures are
> irrelevant.  the resulting C code would certainly look a hell of a lot
> more natural without the useless I/O accessor functions, and be much
> tighter.

Well, so far *no* volatiles have been used in the BFIN CAN driver. But
if you tell me that they are really required for blackfin... I can't
really judge.

> at any rate, the common Blackfin I/O accessor functions force a lot of
> useless overhead when used here as they're designed for async memory,
> not MMRs.  the driver needs to be switched to the bfin_read/bfin_write
> MMR functions.

I just brought up this issue in another mail.

Wolfgang.

> 
> 
