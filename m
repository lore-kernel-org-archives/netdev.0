From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] ravb: stop reading ECMR in ravb_emac_init()
Date: Mon, 11 Jan 2016 10:45:36 +0100
Message-ID: <CAMuHMdUAHYbpxVbqn=j37GKH=3PSzrfRjmqQkGPmPsqxy9XioQ@mail.gmail.com>
References: <5859243.yu8qorLmay@wasted.cogentembedded.com>
	<1554972.rhPQTyRgNp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1554972.rhPQTyRgNp@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On Sun, Jan 10, 2016 at 10:27 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> The code in ravb_emac_init() twiddling the ECMR bits always looked a bit
> strange to me: if one intends to respect 'priv->duplex', why save old value
> of the ECMR.DM bit?   As all the other bits are zeroed anyway, we don't
> really need to read ECMR before writing to it.

Just an observation, I don't know about correctness: priv->duplex wasn't
respected if ECMR_DM was already set before.

Same comment for the second patch.

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
>  drivers/net/ethernet/renesas/ravb_main.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> Index: net/drivers/net/ethernet/renesas/ravb_main.c
> ===================================================================
> --- net.orig/drivers/net/ethernet/renesas/ravb_main.c
> +++ net/drivers/net/ethernet/renesas/ravb_main.c
> @@ -338,16 +338,13 @@ error:
>  static void ravb_emac_init(struct net_device *ndev)
>  {
>         struct ravb_private *priv = netdev_priv(ndev);
> -       u32 ecmr;
>
>         /* Receive frame limit set register */
>         ravb_write(ndev, ndev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN, RFLR);
>
>         /* PAUSE prohibition */
> -       ecmr =  ravb_read(ndev, ECMR);
> -       ecmr &= ECMR_DM;

Perhaps you misread as "ecmr &= ~ECMR_DM"?

> -       ecmr |= ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
> -       ravb_write(ndev, ecmr, ECMR);
> +       ravb_write(ndev, ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) |
> +                  ECMR_TE | ECMR_RE, ECMR);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
