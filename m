From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH linux-next] hisax: disable build for big-endian arm
Date: Fri, 22 Nov 2013 10:19:07 +0100
Message-ID: <CAMuHMdXXO2Rnkaac8_-a91Pob53V=Zs7huirCMpA1ha+oWaHBw@mail.gmail.com>
References: <1385077794-17022-1-git-send-email-vincent.stehle@laposte.net>
	<s5hzjowhp2l.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Vincent_Stehl=C3=A9?= <vincent.stehle@laposte.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux-Next <linux-next@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <s5hzjowhp2l.wl%tiwai@suse.de>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 22, 2013 at 8:29 AM, Takashi Iwai <tiwai@suse.de> wrote:
>>  config HISAX_TELESPCI
>>       bool "Teles PCI"
>> -     depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
>> +     depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || (ARM && !CPU_LITTLE_ENDIAN)))
>
> Isn't it a bit better to exclude CPU_LITTLE_ENDIAN globally?
>
>         depends on PCI && CPU_LITTLE_ENDIAN && (BROKEN || !(SPARC || PPC || PARISC || M68K || MIPS || FRV || XTENSA || ARM))

CPU_LITTLE_ENDIAN is not defined on all little endian platforms,
only on those that can support both big and little endian.

But I guess it wouldn't hurt to move CPU_{BIG,LITTLE}_ENDIAN to
a common Kconfig file.

> Or maybe just
>
>         depends on PCI && (X86 || BROKEN)
>
> (Alpha?  Can anyone test? :)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
