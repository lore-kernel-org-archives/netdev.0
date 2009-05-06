From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 06 May 2009 15:41:38 -0500
Message-ID: <4A01F602.2010601@freescale.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-3-git-send-email-wd@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Piotr Ziecik <kosmo@semihalf.com>,
	John Rigby <jrigby@gmail.com>, netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58722 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761488AbZEFUly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:41:54 -0400
In-Reply-To: <1241640919-4650-3-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang Denk wrote:
> +/*
> + *	Define the buffer descriptor structure.
> + */
> +typedef struct bufdesc {
> +	ushort	cbd_sc;			/* Control and status info */
> +	ushort	cbd_datlen;		/* Data length */
> +	uint	cbd_bufaddr;		/* Buffer address */
> +} cbd_t;
> +
> +/*
> + *	The following definitions courtesy of commproc.h, which where
> + *	Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
> + */
> +#define BD_SC_WRAP		((ushort)0x2000)
> +
> +/*
> + * Buffer descriptor control/status used by Ethernet receive.
> + */
> +#define BD_ENET_RX_EMPTY	((ushort)0x8000)
> +#define BD_ENET_RX_WRAP		((ushort)0x2000)
> +#define BD_ENET_RX_INTR		((ushort)0x1000)
> +#define BD_ENET_RX_LAST		((ushort)0x0800)
> +#define BD_ENET_RX_FIRST	((ushort)0x0400)
> +#define BD_ENET_RX_MISS		((ushort)0x0100)
> +#define BD_ENET_RX_LG		((ushort)0x0020)
> +#define BD_ENET_RX_NO		((ushort)0x0010)
> +#define BD_ENET_RX_SH		((ushort)0x0008)
> +#define BD_ENET_RX_CR		((ushort)0x0004)
> +#define BD_ENET_RX_OV		((ushort)0x0002)
> +#define BD_ENET_RX_CL		((ushort)0x0001)
> +#define BD_ENET_RX_STATS	((ushort)0x013f)	/* All status bits */
> +
> +/*
> + * Buffer descriptor control/status used by Ethernet transmit.
> + */
> +#define BD_ENET_TX_READY	((ushort)0x8000)
> +#define BD_ENET_TX_PAD		((ushort)0x4000)
> +#define BD_ENET_TX_WRAP		((ushort)0x2000)
> +#define BD_ENET_TX_INTR		((ushort)0x1000)
> +#define BD_ENET_TX_LAST		((ushort)0x0800)
> +#define BD_ENET_TX_TC		((ushort)0x0400)
> +#define BD_ENET_TX_DEF		((ushort)0x0200)
> +#define BD_ENET_TX_HB		((ushort)0x0100)
> +#define BD_ENET_TX_LC		((ushort)0x0080)
> +#define BD_ENET_TX_RL		((ushort)0x0040)
> +#define BD_ENET_TX_UN		((ushort)0x0002)
> +#define BD_ENET_TX_CSL		((ushort)0x0001)
> +#define BD_ENET_TX_STATS	((ushort)0x03ff)	/* All status bits */

All of the above is duplicative (with even the same names) of stuff in 
asm/cpm.h.  Beyond just the duplication, what happens if both CPM2 and 
512x are enabled in the same kernel?

-Scott
