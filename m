From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] ravb: factor out register bit twiddling code
Date: Sun, 7 Feb 2016 21:48:39 +0100
Message-ID: <CAMuHMdUSepk+9sdp0tXGoVa4Bz2Xjc8hPbxbyS9PwO78gmLe+w@mail.gmail.com>
References: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
	<28533982.EPUhcRErZl@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <28533982.EPUhcRErZl@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Sun, Feb 7, 2016 at 8:30 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> --- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
> +++ net-next/drivers/net/ethernet/renesas/ravb_main.c
> @@ -2,7 +2,7 @@
>   *
>   * Copyright (C) 2014-2015 Renesas Electronics Corporation
>   * Copyright (C) 2015 Renesas Solutions Corp.
> - * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
> + * Copyright (C) 2015-2016 Cogent Embedded, Inc. <source@cogentembedded.com>
>   *
>   * Based on the SuperH Ethernet driver
>   *
> @@ -42,6 +42,12 @@
>                  NETIF_MSG_RX_ERR | \
>                  NETIF_MSG_TX_ERR)
>
> +void ravb_modify(struct net_device *ndev, enum ravb_reg reg, u32 mask,
> +                u32 value)
> +{
> +       ravb_write(ndev, (ravb_read(ndev, reg) & ~mask) | value, reg);
> +}

Usually "mask"is used for the bits to keep, not for the bits to clear.

So I'd either
  1. AND with "mask" instead of "~mask", and update all callers, or
  2. rename "mask" to "clear", and "value" to "set".

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
