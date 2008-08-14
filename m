From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ne: Use CONFIG_MACH_TX49XX
Date: Thu, 14 Aug 2008 04:44:53 -0400
Message-ID: <48A3F085.9060603@garzik.org>
References: <20080808.005517.96686714.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36253 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752315AbYHNIo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:44:57 -0400
In-Reply-To: <20080808.005517.96686714.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> After some cleanups in arch/mips area, now MACH_TX49XX is selected for
> both TOSHIBA_RBTX4927 and TOSHIBA_RBTX4938.  Fold these two conditions
> to one.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
>  drivers/net/Kconfig |    2 +-
>  drivers/net/ne.c    |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 8a03875..b6c1717 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1171,7 +1171,7 @@ config ETH16I
>  
>  config NE2000
>  	tristate "NE2000/NE1000 support"
> -	depends on NET_ISA || (Q40 && m) || M32R || TOSHIBA_RBTX4927 || TOSHIBA_RBTX4938
> +	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
>  	select CRC32
>  	---help---
>  	  If you have a network (Ethernet) card of this type, say Y and read
> diff --git a/drivers/net/ne.c b/drivers/net/ne.c
> index 42443d6..fa3ceca 100644
> --- a/drivers/net/ne.c
> +++ b/drivers/net/ne.c
> @@ -118,7 +118,7 @@ bad_clone_list[] __initdata = {
>      {"E-LAN100", "E-LAN200", {0x00, 0x00, 0x5d}}, /* Broken ne1000 clones */
>      {"PCM-4823", "PCM-4823", {0x00, 0xc0, 0x6c}}, /* Broken Advantech MoBo */
>      {"REALTEK", "RTL8019", {0x00, 0x00, 0xe8}}, /* no-name with Realtek chip */
> -#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
> +#ifdef CONFIG_MACH_TX49XX
>      {"RBHMA4X00-RTL8019", "RBHMA4X00/RTL8019", {0x00, 0x60, 0x0a}},  /* Toshiba built-in */
>  #endif
>      {"LCS-8834", "LCS-8836", {0x04, 0x04, 0x37}}, /* ShinyNet (SET) */
> @@ -142,7 +142,7 @@ bad_clone_list[] __initdata = {
>  #if defined(CONFIG_PLAT_MAPPI)
>  #  define DCR_VAL 0x4b

applied


