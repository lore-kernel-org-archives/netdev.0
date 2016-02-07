From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/2] sh_eth: factor out register bit twiddling code
Date: Sun, 7 Feb 2016 21:49:50 +0100
Message-ID: <CAMuHMdW5p3w4MPxQoPqrrmX1W6WE40SEOZKwp6YEVqhmy49_6g@mail.gmail.com>
References: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
	<16172313.gq61xOomR3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <16172313.gq61xOomR3@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Sun, Feb 7, 2016 at 8:30 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> --- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
> +++ net-next/drivers/net/ethernet/renesas/sh_eth.c
> @@ -428,6 +428,13 @@ static u32 sh_eth_read(struct net_device
>         return ioread32(mdp->addr + offset);
>  }
>
> +static void sh_eth_modify(struct net_device *ndev, int enum_index, u32 mask,
> +                         u32 value)
> +{
> +       sh_eth_write(ndev, (sh_eth_read(ndev, enum_index) & ~mask) | value,
> +                    enum_index);
> +}

Same comment as for ravb:

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
