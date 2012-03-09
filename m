From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Fri, 9 Mar 2012 08:32:41 -0500
Message-ID: <4F5A0679.1020604@windriver.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com> <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Schmitz <schmitzmic@googlemail.com>,
	<linux-m68k@vger.kernel.org>, <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-03-09 01:35 AM, Geert Uytterhoeven wrote:
> On Fri, Mar 9, 2012 at 04:11, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
>>> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
>>> index f92ea2a..28b8781 100644
>>> --- a/drivers/net/ethernet/8390/ne.c
>>> +++ b/drivers/net/ethernet/8390/ne.c
>>> @@ -55,6 +55,9 @@ static const char version2[] =
>>>
>>>  #include <asm/system.h>
>>>  #include <asm/io.h>
>>> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>>> +#include <asm/atariints.h>
>>> +#endif
>>
>> Do you really need the #if here?  Should be avoidable.
> 
> <asm/atariints.h> exists on m68k only, and is not included by any header in
> arch/m68k/include/.

This kind of arch specific stuff still shouldn't need to
bubble right up to the driver level  I'd think a driver
should be able to include <asm/irq.h> and have whatever
arch specific goo like this be present.

So maybe this kind of magic should be in arch/m68k/include/asm/irq*
instead of here?

And on re-reading the comments in the other part of the patch, i.e.
"...emulates the card interrupt via a timer"  --perhaps the driver
should be just fixed to support generic netpoll, instead of adding
an arch specific thing that amounts to netpoll.  Then anyone can
attempt to limp along and use one of these ancient relics w/o IRQ.

Paul.
--

> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
