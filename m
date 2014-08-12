From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] m68k/atari: EtherNEC - ethernet support (ne),>
Date: Tue, 12 Aug 2014 10:55:46 -0400
Message-ID: <53EA2AF2.3040709@windriver.com>
References: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <geert@linux-m68k.org>, <debian-68k@lists.debian.org>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	Michael Schmitz <schmitz@debian.org>
To: Michael Schmitz <schmitzmic@gmail.com>,
	<linux-m68k@vger.kernel.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1407636153-24864-1-git-send-email-schmitzmic@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Subject added from patch]

On 14-08-09 10:02 PM, Michael Schmitz wrote:
> new version of the patch adding Atari EtherNEC (IRQ-less ROM port ISA NE2k
> adapter) support to ne.c, as announced before.
> 
> Thanks,
> 
> 	Michael Schmitz

Please don't send subjectless mails by attaching a commit to a mail,
just use git send-email directly.

> 
> From 224ce049f71577d6ec380aeb94a4d25c3c4016a7 Mon Sep 17 00:00:00 2001
> From: Michael Schmitz <schmitzmic@gmail.com>
> Date: Sat, 6 Apr 2013 13:26:42 +1300
> Subject: [PATCH] m68k/atari: EtherNEC - ethernet support (ne)
> 
> Support for Atari EtherNEC ROM port adapters in ne.c

Is that all there is to say about these?  Nothing about which platforms
might have it, or what it was tested on or ... ?

> 
> Signed-off-by: Michael Schmitz <schmitz@debian.org>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  drivers/net/ethernet/8390/Kconfig |    3 ++-
>  drivers/net/ethernet/8390/ne.c    |    2 ++
>  2 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
> index 0988811..2d89bd0 100644
> --- a/drivers/net/ethernet/8390/Kconfig
> +++ b/drivers/net/ethernet/8390/Kconfig
> @@ -91,7 +91,8 @@ config MCF8390
>  
>  config NE2000
>  	tristate "NE2000/NE1000 support"
> -	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX)
> +	depends on (ISA || (Q40 && m) || M32R || MACH_TX49XX || \
> +		    ATARI_ETHERNEC)
>  	select CRC32
>  	---help---
>  	  If you have a network (Ethernet) card of this type, say Y and read
> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
> index 58eaa8f..de566fb 100644
> --- a/drivers/net/ethernet/8390/ne.c
> +++ b/drivers/net/ethernet/8390/ne.c
> @@ -169,6 +169,8 @@ bad_clone_list[] __initdata = {
>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
>     defined(CONFIG_MACH_TX49XX)
>  #  define DCR_VAL 0x48		/* 8-bit mode */
> +#elif defined(CONFIG_ATARI)	/* 8-bit mode on Atari, normal on Q40 */
> +#  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)

This doesn't make sense.  Is not MACH_IS_ATARI set when CONFIG_ATARI
is set?  And even if it isn't then just set 48 for MACH_IS_ATARI and
let the default of 49 below take the ATARI=y and IS_ATARI=n case,
without the need for the ?: operator at all.  On top of that, why
aren't you using the ATARI_ETHERNEC option here for your 48 trigger,
instead of the much higher arch/mach level triggers at all?

P.
--

>  #else
>  #  define DCR_VAL 0x49
>  #endif
> 
