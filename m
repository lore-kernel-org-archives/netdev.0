From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - ethernet support (ne),>
Date: Tue, 12 Aug 2014 17:16:28 +0200
Message-ID: <CAMuHMdW+7YH9Z1f=3pBO2OQLQqGRpHQic1MmAwnOsCCWp-Q-KQ@mail.gmail.com>
References: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>
	<53EA2AF2.3040709@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Schmitz <schmitzmic@gmail.com>,
	"Linux/m68k" <linux-m68k@vger.kernel.org>,
	Debian m68k <debian-68k@lists.debian.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Schmitz <schmitz@debian.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <53EA2AF2.3040709@windriver.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul,

On Tue, Aug 12, 2014 at 4:55 PM, Paul Gortmaker
<paul.gortmaker@windriver.com> wrote:
>> @@ -169,6 +169,8 @@ bad_clone_list[] __initdata = {
>>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
>>     defined(CONFIG_MACH_TX49XX)
>>  #  define DCR_VAL 0x48               /* 8-bit mode */
>> +#elif defined(CONFIG_ATARI)  /* 8-bit mode on Atari, normal on Q40 */
>> +#  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
>
> This doesn't make sense.  Is not MACH_IS_ATARI set when CONFIG_ATARI
> is set?  And even if it isn't then just set 48 for MACH_IS_ATARI and

m68k kernels can be multi-platform, so we need the MACH_IS_ATARI()
runtime check.

> let the default of 49 below take the ATARI=y and IS_ATARI=n case,
> without the need for the ?: operator at all.  On top of that, why
> aren't you using the ATARI_ETHERNEC option here for your 48 trigger,
> instead of the much higher arch/mach level triggers at all?

CONFIG_ATARI_ETHERNEC could be used instead of CONFIG_ATARI,
but as ne.c is used on Atari with Ethernec only, it doesn't matter much.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
