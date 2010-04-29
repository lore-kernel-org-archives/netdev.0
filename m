From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 11:24:24 +0200
Message-ID: <4BD95048.7050606@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com> <20100428054706.GA4516@riccoc20.at.omicron.at> <4BD83D37.4060301@grandegger.com> <4BD846C7.1050006@grandegger.com> <20100429083833.GA4629@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:44211 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933647Ab0D3SI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:08:59 -0400
In-Reply-To: <20100429083833.GA4629@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Wed, Apr 28, 2010 at 04:31:35PM +0200, Wolfgang Grandegger wrote:
>> That's because some 1588_PPS related bits are not yet setup in the
>> platform code of mainline kernel.
> 
> Just remembered, I am carrying along the following patch to fix the
> wrong mainline code for the mpc8313. Really annoying.

OK.

> Richard
> 
>>From 4306b6f89e5565928b4462fd8cff19a3e484f1c4 Mon Sep 17 00:00:00 2001
> From: Richard Cochran <richard.cochran@omicron.at>
> Date: Tue, 6 Apr 2010 13:36:32 +0200
> Subject: [PATCH] mpc8313: fixed the board support for REV C
> 
> ---
>  arch/powerpc/boot/dts/mpc8313erdb.dts     |   56 ++++++++++++++++++++++------
>  arch/powerpc/platforms/83xx/mpc831x_rdb.c |   15 ++++++++
>  2 files changed, 59 insertions(+), 12 deletions(-)
> 
> diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
> index 761faa7..183f2aa 100644
> --- a/arch/powerpc/boot/dts/mpc8313erdb.dts
> +++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
> @@ -70,6 +70,26 @@
>  			reg = <0x0 0x0 0x800000>;
>  			bank-width = <2>;
>  			device-width = <1>;
> +			partition@0 {
> +				label = "U-Boot";
> +				reg = <0x00000000 0x00100000>;
> +			};
> +			partition@100000 {
> +				label = "kernel";
> +				reg = <0x00100000 0x00200000>;
> +			};
> +			partition@300000 {
> +				label = "rootfs";
> +				reg = <0x00300000 0x00400000>;
> +			};
> +			partition@700000 {
> +				label = "DTB";
> +				reg = <0x00700000 0x00010000>;
> +			};
> +			partition@710000 {
> +				label = "vsc-util";
> +				reg = <0x00710000 0x000F0000>;
> +			};
>  		};
>  
>  		nand@1,0 {
> @@ -78,19 +98,31 @@
>  			compatible = "fsl,mpc8313-fcm-nand",
>  			             "fsl,elbc-fcm-nand";
>  			reg = <0x1 0x0 0x2000>;
> -
> -			u-boot@0 {
> -				reg = <0x0 0x100000>;
> -				read-only;
> +			partition@0 {
> +				label = "U-Boot-NAND";
> +				reg = <0x00000000 0x00100000>;
>  			};
> -
> -			kernel@100000 {
> -				reg = <0x100000 0x300000>;
> +			partition@100000 {
> +				label = "JFFS2-NAND";
> +				reg = <0x00100000 0x00800000>;
>  			};
> -
> -			fs@400000 {
> -				reg = <0x400000 0x1c00000>;
> +			partition@900000 {
> +				label = "Ramdisk-NAND";
> +				reg = <0x00900000 0x00400000>;
> +			};
> +			partition@d00000 {
> +				label = "Reserve-NAND";
> +				reg = <0x00d00000 0x01000000>;
>  			};
> +			partition@1d00000 {
> +				label = "Kernel-NAND";
> +				reg = <0x01d00000 0x00200000>;
> +			};
> +			partition@1f00000 {
> +				label = "DTB-NAND";
> +				reg = <0x01f00000 0x00100000>;
> +			};
> +
>  		};
>  	};
>  
> @@ -188,7 +220,7 @@
>  			compatible = "gianfar";
>  			reg = <0x24000 0x1000>;
>  			local-mac-address = [ 00 00 00 00 00 00 ];
> -			interrupts = <37 0x8 36 0x8 35 0x8>;
> +			interrupts = <32 0x8 33 0x8 34 0x8>;
>  			interrupt-parent = <&ipic>;
>  			tbi-handle = < &tbi0 >;
>  			/* Vitesse 7385 isn't on the MDIO bus */
> @@ -223,7 +255,7 @@
>  			reg = <0x25000 0x1000>;
>  			ranges = <0x0 0x25000 0x1000>;
>  			local-mac-address = [ 00 00 00 00 00 00 ];
> -			interrupts = <34 0x8 33 0x8 32 0x8>;
> +			interrupts = <35 0x8 36 0x8 37 0x8>;

I used these interrupt number fixes as well but it was not necessary for
the actual net-next-2.6 tree. Need to check why? I remember some version
dependent re-mapping code.

>  			interrupt-parent = <&ipic>;
>  			tbi-handle = < &tbi1 >;
>  			phy-handle = < &phy4 >;
> diff --git a/arch/powerpc/platforms/83xx/mpc831x_rdb.c b/arch/powerpc/platforms/83xx/mpc831x_rdb.c
> index 0b4f883..7f80269 100644
> --- a/arch/powerpc/platforms/83xx/mpc831x_rdb.c
> +++ b/arch/powerpc/platforms/83xx/mpc831x_rdb.c
> @@ -20,6 +20,7 @@
>  #include <asm/ipic.h>
>  #include <asm/udbg.h>
>  #include <sysdev/fsl_pci.h>
> +#include <sysdev/fsl_soc.h>
>  
>  #include "mpc83xx.h"
>  
> @@ -31,6 +32,8 @@ static void __init mpc831x_rdb_setup_arch(void)
>  #ifdef CONFIG_PCI
>  	struct device_node *np;
>  #endif
> +	void __iomem *immap;
> +	unsigned long spcr, sicrh;
>  
>  	if (ppc_md.progress)
>  		ppc_md.progress("mpc831x_rdb_setup_arch()", 0);
> @@ -42,6 +45,18 @@ static void __init mpc831x_rdb_setup_arch(void)
>  		mpc83xx_add_bridge(np);
>  #endif
>  	mpc831x_usb_cfg();
> +
> +#define MPC83XX_SPCR_OFFS         0x110
> +#define MPC8313_SPCR_1588_PPS 0x00004000
> +#define MPC8313_SICRH_1588_PPS 0x01000000
> +
> +	immap = ioremap(get_immrbase(), 0x1000);
> +	spcr = in_be32(immap + MPC83XX_SPCR_OFFS);
> +	sicrh = in_be32(immap + MPC83XX_SICRH_OFFS);
> +	sicrh |= MPC8313_SICRH_1588_PPS;
> +	out_be32(immap + MPC83XX_SICRH_OFFS, sicrh);
> +	spcr |= MPC8313_SPCR_1588_PPS;
> +	out_be32(immap + MPC83XX_SPCR_OFFS, spcr);
>  }

That's missing to get the PPS signal output. But it should probably go
to gianfar_ptp.c.

Wolfgang.
