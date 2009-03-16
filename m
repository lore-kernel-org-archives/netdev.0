From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-2.6 PATCH 5/10] Neterion: New driver: register set -
	vxge-reg.h
Date: Mon, 16 Mar 2009 21:03:42 +0000
Message-ID: <1237237422.3106.34.camel@achroite>
References: <1237018876.4966.429.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:42770 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801AbZCPVDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 17:03:52 -0400
In-Reply-To: <1237018876.4966.429.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 00:21 -0800, Ramkrishna Vepa wrote:
> - Complete Register map details of Neterion Inc's X3100 Series 10GbE =
PCIe I/O
>   Virtualized Server Adapter.
> ---
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch_4/drivers/net/vxge/vxge-reg.h patch_5/drivers/net/vx=
ge/vxge-reg.h
> --- patch_4/drivers/net/vxge/vxge-reg.h	1969-12-31 16:00:00.000000000=
 -0800
> +++ patch_5/drivers/net/vxge/vxge-reg.h	2009-03-13 00:10:23.000000000=
 -0700
[...]
> +#define VXGE_HW_PCI_CONFIG_SPACE_SIZE	VXGE_OS_PCI_CONFIG_SIZE
> +#define VXGE_OS_PCI_CONFIG_SIZE	1024
> +
> +#ifdef __BIG_ENDIAN
> +#define VXGE_OS_HOST_BIG_ENDIAN		1
> +#define VXGE_OS_PIO_LITTLE_ENDIAN	1
> +#elif __LITTLE_ENDIAN
> +#define VXGE_OS_HOST_LITTLE_ENDIAN	1
> +#endif
=EF=BB=BF
=EF=BB=BFWhat's wrong with the original macros?

> +#if BITS_PER_LONG =3D=3D 64
> +#define VXGE_OS_PLATFORM_64BIT		1
> +#elif BITS_PER_LONG =3D=3D 32
> +#define VXGE_OS_PLATFORM_32BIT		1
> +#endif
> +
> +#if !defined(VXGE_OS_PLATFORM_64BIT) && !defined(VXGE_OS_PLATFORM_32=
BIT)
> +#error "either 32bit or 64bit switch must be defined!"
> +#endif

The VXGE_OS_PLATFORM_* macros aren't even used in this header, and in
any case they are redundant with BITS_PER_LONG.

> +#if !defined(VXGE_OS_HOST_BIG_ENDIAN) && !defined(VXGE_OS_HOST_LITTL=
E_ENDIAN)
> +#error "either little endian or big endian switch must be defined!"
> +#endif

It would be simpler just to include <asm/byteorder.h>.

> +/*
> + * vxge_mBIT(loc) - set bit at offset
> + */
> +#define vxge_mBIT(loc)		(0x8000000000000000ULL >> (loc))
> +
> +/*
> + * vxge_vBIT(val, loc, sz) - set bits at offset
> + */
> +#define vxge_vBIT(val, loc, sz)	(((u64)(val)) << (64-(loc)-(sz)))
> +#define vxge_vBIT32(val, loc, sz)	(((u32)(val)) << (32-(loc)-(sz)))
> +
> +/*
> + * bVALx(bits, loc) - Get the value of x bits at location
> + */
> +#define bVAL1(bits, loc)  ((((u64)bits) >> (64-(loc+1))) & 0x1)
> +#define bVAL2(bits, loc)  ((((u64)bits) >> (64-(loc+2))) & 0x3)
> +#define bVAL3(bits, loc)  ((((u64)bits) >> (64-(loc+3))) & 0x7)
> +#define bVAL4(bits, loc)  ((((u64)bits) >> (64-(loc+4))) & 0xF)
> +#define bVAL5(bits, loc)  ((((u64)bits) >> (64-(loc+5))) & 0x1F)
> +#define bVAL6(bits, loc)  ((((u64)bits) >> (64-(loc+6))) & 0x3F)
> +#define bVAL7(bits, loc)  ((((u64)bits) >> (64-(loc+7))) & 0x7F)
> +#define bVAL8(bits, loc)  ((((u64)bits) >> (64-(loc+8))) & 0xFF)
> +#define bVAL9(bits, loc)  ((((u64)bits) >> (64-(loc+9))) & 0x1FF)
> +#define bVAL11(bits, loc) ((((u64)bits) >> (64-(loc+11))) & 0x7FF)
> +#define bVAL12(bits, loc) ((((u64)bits) >> (64-(loc+12))) & 0xFFF)
> +#define bVAL14(bits, loc) ((((u64)bits) >> (64-(loc+14))) & 0x3FFF)
> +#define bVAL15(bits, loc) ((((u64)bits) >> (64-(loc+15))) & 0x7FFF)
> +#define bVAL16(bits, loc) ((((u64)bits) >> (64-(loc+16))) & 0xFFFF)
> +#define bVAL17(bits, loc) ((((u64)bits) >> (64-(loc+17))) & 0x1FFFF)
> +#define bVAL18(bits, loc) ((((u64)bits) >> (64-(loc+18))) & 0x3FFFF)
> +#define bVAL20(bits, loc) ((((u64)bits) >> (64-(loc+20))) & 0xFFFFF)
> +#define bVAL22(bits, loc) ((((u64)bits) >> (64-(loc+22))) & 0x3FFFFF=
)
> +#define bVAL24(bits, loc) ((((u64)bits) >> (64-(loc+24))) & 0xFFFFFF=
)
> +#define bVAL28(bits, loc) ((((u64)bits) >> (64-(loc+28))) & 0xFFFFFF=
=46)
> +#define bVAL32(bits, loc) ((((u64)bits) >> (64-(loc+32))) & 0xFFFFFF=
=46F)
> +#define bVAL36(bits, loc) ((((u64)bits) >> (64-(loc+36))) & 0xFFFFFF=
=46FFULL)
> +#define bVAL40(bits, loc) ((((u64)bits) >> (64-(loc+40))) & 0xFFFFFF=
=46FFFULL)
> +#define bVAL44(bits, loc) ((((u64)bits) >> (64-(loc+44))) & 0xFFFFFF=
=46FFFFULL)
> +#define bVAL48(bits, loc) ((((u64)bits) >> (64-(loc+48))) & 0xFFFFFF=
=46FFFFFULL)
> +#define bVAL52(bits, loc) ((((u64)bits) >> (64-(loc+52))) & 0xFFFFFF=
=46FFFFFFULL)
> +#define bVAL56(bits, loc) ((((u64)bits) >> (64-(loc+56))) & 0xFFFFFF=
=46FFFFFFFULL)
> +#define bVAL60(bits, loc) ((((u64)bits) >> (64-(loc+60))) & \
> +					0xFFFFFFFFFFFFFFFULL)
> +#define bVAL61(bits, loc) ((((u64)bits) >> (64-(loc+61))) & \
> +					0x1FFFFFFFFFFFFFFFULL)

Wow.  Why don't you make the width a parameter too?

[...]
> +#pragma pack(1)

We don't use Microsoft extensions, even if gcc does now understand this
one.  Use the __packed macro at the end of each structure definition
instead.

> +struct vxge_hw_legacy_reg {
> +
> +	u8	unused00010[0x00010];
> +
> +/*0x00010*/	u64	toc_swapper_fb;
> +#define VXGE_HW_TOC_SWAPPER_FB_INITIAL_VAL(val) vxge_vBIT(val, 0, 64=
)
> +/*0x00018*/	u64	pifm_rd_swap_en;
> +#define VXGE_HW_PIFM_RD_SWAP_EN_PIFM_RD_SWAP_EN(val) vxge_vBIT(val, =
0, 64)
> +/*0x00020*/	u64	pifm_rd_flip_en;
> +#define VXGE_HW_PIFM_RD_FLIP_EN_PIFM_RD_FLIP_EN(val) vxge_vBIT(val, =
0, 64)
> +/*0x00028*/	u64	pifm_wr_swap_en;
> +#define VXGE_HW_PIFM_WR_SWAP_EN_PIFM_WR_SWAP_EN(val) vxge_vBIT(val, =
0, 64)
> +/*0x00030*/	u64	pifm_wr_flip_en;
> +#define VXGE_HW_PIFM_WR_FLIP_EN_PIFM_WR_FLIP_EN(val) vxge_vBIT(val, =
0, 64)
> +/*0x00038*/	u64	toc_first_pointer;
> +#define VXGE_HW_TOC_FIRST_POINTER_INITIAL_VAL(val) vxge_vBIT(val, 0,=
 64)
> +/*0x00040*/	u64	host_access_en;
> +#define VXGE_HW_HOST_ACCESS_EN_HOST_ACCESS_EN(val) vxge_vBIT(val, 0,=
 64)
> +
> +};

If this structure is supposed to represent memory-mapped registers
(which is rarely a good idea) then you should make the byte order of
these registers explicit.

[...]
> +/* Using this strcture to calculate offsets */
> +struct vxge_hw_pci_config_le {
> +	u16     vendor_id;              /* 0x00 */
> +	u16     device_id;              /* 0x02 */
> +
> +	u16     command;                /* 0x04 */
> +	u16     status;                 /* 0x06 */
[...]

This is duplicating definitions in <linux/pci_regs.h>.  Use those
instead.

[...]
> +/* Capability lists */
[...]

Registers in PCI capabilities are mostly defined in <linux/pci_regs.h>
too.  If any register definitions are missing from that please add them
there.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

