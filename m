From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Mon, 05 Apr 2010 23:29:53 +0200
Message-ID: <1270502993.9013.36.camel@edumazet-laptop>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: John Linn <john.linn@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42529 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756379Ab0DEV37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 17:29:59 -0400
Received: by bwz1 with SMTP id 1so3117092bwz.21
        for <netdev@vger.kernel.org>; Mon, 05 Apr 2010 14:29:57 -0700 (PDT)
In-Reply-To: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 avril 2010 =C3=A0 15:11 -0600, John Linn a =C3=A9crit :
> This patch adds support for using the LL TEMAC Ethernet driver on
> non-Virtex 5 platforms by adding support for accessing the Soft DMA
> registers as if they were memory mapped instead of solely through the
> DCR's (available on the Virtex 5).
>=20
> The patch also updates the driver so that it runs on the MicroBlaze.
> The changes were tested on the PowerPC 440, PowerPC 405, and the
> MicroBlaze platforms.
>=20
> Signed-off-by: John Tyner <jtyner@cs.ucr.edu>
> Signed-off-by: John Linn <john.linn@xilinx.com>
>=20
> ---

> +/* Align the IP data in the packet on word boundaries as MicroBlaze
> + * needs it.
> + */
> +
>  #define XTE_ALIGN       32
> -#define BUFFER_ALIGN(adr) ((XTE_ALIGN - ((u32) adr)) % XTE_ALIGN)
> +#define BUFFER_ALIGN(adr) ((34 - ((u32) adr)) % XTE_ALIGN)
> =20

Very interesting way of doing this, but why such convoluted thing ?

Because of the % 32, this is equivalent to :

#define BUFFER_ALIGN(adr) ((2 - ((u32) adr)) % XTE_ALIGN)

But wait, dont we recognise the magic constant NET_IP_ALIGN ?

So, I ask, cant you use netdev_alloc_skb_ip_align() in this driver ?


