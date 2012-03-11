From: Michael Schmitz <schmitzmic@googlemail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Sun, 11 Mar 2012 19:31:28 +1300
Message-ID: <4F5C46C0.3040003@gmail.com>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org>	<4F4B2BB6.900@gmail.com>	<CAP=VYLqxtE4OamrdN2RXaQu_2kK5_57-x80z48JXzt+xEtQ7pw@mail.gmail.com> <CAMuHMdX=4Vn=OsNTp04YcrhDOwz8NOFrWKankj2+3utvEfE-2A@mail.gmail.com> <4F5A0679.1020604@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Michael Schmitz <schmitzmic@googlemail.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F5A0679.1020604@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Gortmaker wrote:
>> <asm/atariints.h> exists on m68k only, and is not included by any header in
>> arch/m68k/include/.
>>     
>
> This kind of arch specific stuff still shouldn't need to
> bubble right up to the driver level  I'd think a driver
> should be able to include <asm/irq.h> and have whatever
> arch specific goo like this be present.
>
> So maybe this kind of magic should be in arch/m68k/include/asm/irq*
> instead of here?
>   
I've double checked - that hunk should not actually have been in the 
patch at all. My bad ...
With all arch-specific interrupt tweaks (aside from the  interrupt 
flags) now removed from the driver, the definition wasn't actually used 
any longer in the main driver file.

The non-standard interrupt flag will still be required for those users 
that decide to wire up the card interrupt line to, for example, the 
modem serial port's ring input.
> And on re-reading the comments in the other part of the patch, i.e.
> "...emulates the card interrupt via a timer"  --perhaps the driver
> should be just fixed to support generic netpoll, instead of adding
> an arch specific thing that amounts to netpoll.  Then anyone can
> attempt to limp along and use one of these ancient relics w/o IRQ.
>   
I had in fact implemented that as a fallback option earlier, and it 
turned out to be quite a bit slower that way.
If that's the preferred option, I'll add netpoll to the 8390 driver and 
resubmit.

Thanks,

  Michael
