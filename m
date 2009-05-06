From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 6 May 2009 14:33:54 -0600
Message-ID: <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-3-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, netdev@vger.kernel.org,
	John Rigby <jcrigby@gmail.com>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:34600 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbZEFUeO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:34:14 -0400
Received: by yx-out-2324.google.com with SMTP id 3so195346yxj.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 13:34:14 -0700 (PDT)
In-Reply-To: <1241640919-4650-3-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 2:15 PM, Wolfgang Denk <wd@denx.de> wrote:
> From: John Rigby <jrigby@freescale.com>
>
> Add support for MPC512x to fs_enet driver
>
> =A0 =A0drivers/net/fs_enet/*
> =A0 =A0 =A0 =A0Enable fs_enet driver to work 5121 FEC
> =A0 =A0 =A0 =A0Enable it with CONFIG_FS_ENET_MPC5121_FEC
>
> Signed-off-by: John Rigby <jrigby@freescale.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Cc: <netdev@vger.kernel.org>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: John Rigby <jcrigby@gmail.com>
> ---
> =A0arch/powerpc/include/asm/mpc5121_fec.h | =A0111 ++++++++++++++++++=
++++++++++++++
> =A0drivers/net/fs_enet/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 ++-
> =A0drivers/net/fs_enet/fs_enet-main.c =A0 =A0 | =A0 =A07 ++
> =A0drivers/net/fs_enet/fs_enet.h =A0 =A0 =A0 =A0 =A0| =A0 =A06 ++
> =A0drivers/net/fs_enet/mac-fec.c =A0 =A0 =A0 =A0 =A0| =A0 30 ++++++++=
-
> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0 =A0 =A0| =A0 =A07 ++
> =A06 files changed, 166 insertions(+), 5 deletions(-)
> =A0create mode 100644 arch/powerpc/include/asm/mpc5121_fec.h
>
> diff --git a/arch/powerpc/include/asm/mpc5121_fec.h b/arch/powerpc/in=
clude/asm/mpc5121_fec.h
> new file mode 100644
> index 0000000..6bddf0b
> --- /dev/null
> +++ b/arch/powerpc/include/asm/mpc5121_fec.h
> @@ -0,0 +1,111 @@
> +/*
> + * Copyright (C) 2007,2008 Freescale Semiconductor, Inc. All rights =
reserved.
> + *
> + * Author: John Rigby, <jrigby@freescale.com>
> + *
> + * Modified version of drivers/net/fec.h:
> + *
> + * =A0 =A0 fec.h =A0-- =A0Fast Ethernet Controller for Motorola Cold=
=46ire SoC
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0processors.
> + *
> + * =A0 =A0 (C) Copyright 2000-2005, Greg Ungerer (gerg@snapgear.com)
> + * =A0 =A0 (C) Copyright 2000-2001, Lineo (www.lineo.com)
> + *
> + * This is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +#ifndef MPC5121_FEC_H
> +#define MPC5121_FEC_H
> +
> +typedef struct fec {
> + =A0 =A0 =A0 u32 fec_reserved0;
> + =A0 =A0 =A0 u32 fec_ievent; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Inte=
rrupt event reg */
> + =A0 =A0 =A0 u32 fec_imask; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* In=
terrupt mask reg */
> + =A0 =A0 =A0 u32 fec_reserved1;
> + =A0 =A0 =A0 u32 fec_r_des_active; =A0 =A0 =A0 =A0 =A0 /* Receive de=
scriptor reg */
> + =A0 =A0 =A0 u32 fec_x_des_active; =A0 =A0 =A0 =A0 =A0 /* Transmit d=
escriptor reg */
> + =A0 =A0 =A0 u32 fec_reserved2[3];
> + =A0 =A0 =A0 u32 fec_ecntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Ethe=
rnet control reg */
> + =A0 =A0 =A0 u32 fec_reserved3[6];
> + =A0 =A0 =A0 u32 fec_mii_data; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* MII ma=
nage frame reg */
> + =A0 =A0 =A0 u32 fec_mii_speed; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* MII sp=
eed control reg */
> + =A0 =A0 =A0 u32 fec_reserved4[7];
> + =A0 =A0 =A0 u32 fec_mib_ctrlstat; =A0 =A0 =A0 =A0 =A0 /* MIB contro=
l/status reg */
> + =A0 =A0 =A0 u32 fec_reserved5[7];
> + =A0 =A0 =A0 u32 fec_r_cntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Rece=
ive control reg */
> + =A0 =A0 =A0 u32 fec_reserved6[15];
> + =A0 =A0 =A0 u32 fec_x_cntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Tran=
smit Control reg */
> + =A0 =A0 =A0 u32 fec_reserved7[7];
> + =A0 =A0 =A0 u32 fec_addr_low; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Low 32=
bits MAC address */
> + =A0 =A0 =A0 u32 fec_addr_high; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* High 1=
6bits MAC address */
> + =A0 =A0 =A0 u32 fec_opd; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* =
Opcode + Pause duration */
> + =A0 =A0 =A0 u32 fec_reserved8[10];
> + =A0 =A0 =A0 u32 fec_hash_table_high; =A0 =A0 =A0 =A0/* High 32bits =
hash table */
> + =A0 =A0 =A0 u32 fec_hash_table_low; =A0 =A0 =A0 =A0 /* Low 32bits h=
ash table */
> + =A0 =A0 =A0 u32 fec_grp_hash_table_high; =A0 =A0/* High 32bits hash=
 table */
> + =A0 =A0 =A0 u32 fec_grp_hash_table_low; =A0 =A0 /* Low 32bits hash =
table */
> + =A0 =A0 =A0 u32 fec_reserved9[7];
> + =A0 =A0 =A0 u32 fec_x_wmrk; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* FIFO=
 transmit water mark */
> + =A0 =A0 =A0 u32 fec_reserved10;
> + =A0 =A0 =A0 u32 fec_r_bound; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* FIFO=
 receive bound reg */
> + =A0 =A0 =A0 u32 fec_r_fstart; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* FIFO r=
eceive start reg */
> + =A0 =A0 =A0 u32 fec_reserved11[11];
> + =A0 =A0 =A0 u32 fec_r_des_start; =A0 =A0 =A0 =A0 =A0 =A0/* Receive =
descriptor ring */
> + =A0 =A0 =A0 u32 fec_x_des_start; =A0 =A0 =A0 =A0 =A0 =A0/* Transmit=
 descriptor ring */
> + =A0 =A0 =A0 u32 fec_r_buff_size; =A0 =A0 =A0 =A0 =A0 =A0/* Maximum =
receive buff size */
> + =A0 =A0 =A0 u32 fec_reserved12[26];
> + =A0 =A0 =A0 u32 fec_dma_control; =A0 =A0 =A0 =A0 =A0 =A0/* DMA Endi=
an and other ctrl */
> +} fec_t;
> +
> +/*
> + * =A0 =A0 Define the buffer descriptor structure.
> + */
> +typedef struct bufdesc {
> + =A0 =A0 =A0 ushort =A0cbd_sc; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Co=
ntrol and status info */
> + =A0 =A0 =A0 ushort =A0cbd_datlen; =A0 =A0 =A0 =A0 =A0 =A0 /* Data l=
ength */
> + =A0 =A0 =A0 uint =A0 =A0cbd_bufaddr; =A0 =A0 =A0 =A0 =A0 =A0/* Buff=
er address */
> +} cbd_t;
> +
> +/*
> + * =A0 =A0 The following definitions courtesy of commproc.h, which w=
here
> + * =A0 =A0 Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
> + */
> +#define BD_SC_WRAP =A0 =A0 =A0 =A0 =A0 =A0 ((ushort)0x2000)
> +
> +/*
> + * Buffer descriptor control/status used by Ethernet receive.
> + */
> +#define BD_ENET_RX_EMPTY =A0 =A0 =A0 ((ushort)0x8000)
> +#define BD_ENET_RX_WRAP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x20=
00)
> +#define BD_ENET_RX_INTR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x10=
00)
> +#define BD_ENET_RX_LAST =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x08=
00)
> +#define BD_ENET_RX_FIRST =A0 =A0 =A0 ((ushort)0x0400)
> +#define BD_ENET_RX_MISS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x01=
00)
> +#define BD_ENET_RX_LG =A0 =A0 =A0 =A0 =A0((ushort)0x0020)
> +#define BD_ENET_RX_NO =A0 =A0 =A0 =A0 =A0((ushort)0x0010)
> +#define BD_ENET_RX_SH =A0 =A0 =A0 =A0 =A0((ushort)0x0008)
> +#define BD_ENET_RX_CR =A0 =A0 =A0 =A0 =A0((ushort)0x0004)
> +#define BD_ENET_RX_OV =A0 =A0 =A0 =A0 =A0((ushort)0x0002)
> +#define BD_ENET_RX_CL =A0 =A0 =A0 =A0 =A0((ushort)0x0001)
> +#define BD_ENET_RX_STATS =A0 =A0 =A0 ((ushort)0x013f) =A0 =A0 =A0 =A0=
/* All status bits */
> +
> +/*
> + * Buffer descriptor control/status used by Ethernet transmit.
> + */
> +#define BD_ENET_TX_READY =A0 =A0 =A0 ((ushort)0x8000)
> +#define BD_ENET_TX_PAD =A0 =A0 =A0 =A0 ((ushort)0x4000)
> +#define BD_ENET_TX_WRAP =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x20=
00)
> +#define BD_ENET_TX_INTR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x10=
00)
> +#define BD_ENET_TX_LAST =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0((ushort)0x08=
00)
> +#define BD_ENET_TX_TC =A0 =A0 =A0 =A0 =A0((ushort)0x0400)
> +#define BD_ENET_TX_DEF =A0 =A0 =A0 =A0 ((ushort)0x0200)
> +#define BD_ENET_TX_HB =A0 =A0 =A0 =A0 =A0((ushort)0x0100)
> +#define BD_ENET_TX_LC =A0 =A0 =A0 =A0 =A0((ushort)0x0080)
> +#define BD_ENET_TX_RL =A0 =A0 =A0 =A0 =A0((ushort)0x0040)
> +#define BD_ENET_TX_UN =A0 =A0 =A0 =A0 =A0((ushort)0x0002)
> +#define BD_ENET_TX_CSL =A0 =A0 =A0 =A0 ((ushort)0x0001)
> +#define BD_ENET_TX_STATS =A0 =A0 =A0 ((ushort)0x03ff) =A0 =A0 =A0 =A0=
/* All status bits */
> +
> +#endif /* MPC5121_FEC_H */
> diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfi=
g
> index 562ea68..fc073b5 100644
> --- a/drivers/net/fs_enet/Kconfig
> +++ b/drivers/net/fs_enet/Kconfig
> @@ -1,9 +1,13 @@
> =A0config FS_ENET
> =A0 =A0 =A0 =A0tristate "Freescale Ethernet Driver"
> - =A0 =A0 =A0 depends on CPM1 || CPM2
> + =A0 =A0 =A0 depends on CPM1 || CPM2 || PPC_MPC512x
> =A0 =A0 =A0 =A0select MII
> =A0 =A0 =A0 =A0select PHYLIB
>
> +config FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 def_bool y if (FS_ENET && PPC_MPC512x)
> + =A0 =A0 =A0 select FS_ENET_HAS_FEC
> +
> =A0config FS_ENET_HAS_SCC
> =A0 =A0 =A0 =A0bool "Chip has an SCC usable for ethernet"
> =A0 =A0 =A0 =A0depends on FS_ENET && (CPM1 || CPM2)
> @@ -16,13 +20,13 @@ config FS_ENET_HAS_FCC
>
> =A0config FS_ENET_HAS_FEC
> =A0 =A0 =A0 =A0bool "Chip has an FEC usable for ethernet"
> - =A0 =A0 =A0 depends on FS_ENET && CPM1
> + =A0 =A0 =A0 depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
> =A0 =A0 =A0 =A0select FS_ENET_MDIO_FEC
> =A0 =A0 =A0 =A0default y
>
> =A0config FS_ENET_MDIO_FEC
> =A0 =A0 =A0 =A0tristate "MDIO driver for FEC"
> - =A0 =A0 =A0 depends on FS_ENET && CPM1
> + =A0 =A0 =A0 depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
>
> =A0config FS_ENET_MDIO_FCC
> =A0 =A0 =A0 =A0tristate "MDIO driver for FCC"
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet=
/fs_enet-main.c
> index f996a1a..4170d33 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -1183,11 +1183,18 @@ static struct of_device_id fs_enet_match[] =3D=
 {
> =A0 =A0 =A0 =A0},
> =A0#endif
> =A0#ifdef CONFIG_FS_ENET_HAS_FEC
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .compatible =3D "fsl,mpc5121-fec",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =3D (void *)&fs_fec_ops,
> + =A0 =A0 =A0 },
> +#else
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.compatible =3D "fsl,pq1-fec-enet",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =3D (void *)&fs_fec_ops,
> =A0 =A0 =A0 =A0},
> =A0#endif
> +#endif

Hmmm.  A lot of these #ifdefs in here.  Does this have a multiplatform
impact?  Not to mention the fact that it's just plain ugly.  :-)

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
