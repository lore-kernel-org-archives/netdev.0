From: Michael Schmitz <schmitzmic@gmail.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - ethernet support (ne),>
Date: Wed, 13 Aug 2014 20:37:33 +1200
Message-ID: <53EB23CD.2060101@gmail.com>
References: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>	<53EA2AF2.3040709@windriver.com>	<CAOmrzk+m7b58Xb=zFv6Kf=_HgGR4FzwpwRvsh08uGMkg0xPLWA@mail.gmail.com> <CAMuHMdWqXPf_1a1b=VGGayS2y2DPEibeOpFMFZth6KZUMue6BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux/m68k <linux-m68k@vger.kernel.org>,
	debian m68k <debian-68k@lists.debian.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48441 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647AbaHMIhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 04:37:39 -0400
In-Reply-To: <CAMuHMdWqXPf_1a1b=VGGayS2y2DPEibeOpFMFZth6KZUMue6BQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Geert,

>
>> Would you be OK if I expanded the comment like this?
>>
>> /* ne.c is used on m68k Atari and Q40 computers - the Atari ROM-port
>> adapter is 8-bit, Q40 uses ISA */
>>     
>
> DaveM already applied it to his tree, and sent a pull request to Linus.
>   

OK - won't resend then unless explicitly requested.

Many thanks, Dave!

>> This would limit the runtime test to the case where it is actually
>> needed (untested):
>>
>> #elif defined(CONFIG_ATARI) && defined(CONFIG_Q40)
>> /* multiplatform m68k kernel - the Atari ROM-port adapter is 8-bit,
>> Q40 uses ISA */
>> #  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
>> #elif defined(CONFIG_ATARI) /* no Q40 support - 8-bit mode on Atari ROM port */
>> #  define DCR_VAL 0x48
>> #else
>> #  define DCR_VAL 0x49
>> #endif
>>     
>
> MACH_IS_ATARI already evaluates to a constant on single-platform
> kernels, so this is optimized at compile time.
> Hence there's not really a need for this.
>   

I was hoping it would. More of an attempt to make the logic easier to 
understand, but a comment would be sufficient (and avoid redundancy).

>> Are there any other m68k platforms that use the ne.c driver, Geert?
>> apne, hydra and zorro8390 all have their own separate drivers - any
>> others?
>>     
>
> Not that I'm aware of. Only Q40 has CONFIG_NE2000 in defconfig.
>   

Good - we can finally put this one to rest.

Cheers,

    Michael


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
>   
