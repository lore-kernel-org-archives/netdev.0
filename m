From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/3] rcar_can: print signed IRQ #
Date: Sat, 20 Jun 2015 14:03:04 +0200
Message-ID: <CAMuHMdWZFKR04NJc7xtnPUosYuosX9FPDJopG3wovu_GqGxSOw@mail.gmail.com>
References: <2010452.WyFito6egU@wasted.cogentembedded.com>
	<2390389.thI8mIvbv5@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	wg@grandegger.com, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:32832 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbbFTMDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 08:03:05 -0400
In-Reply-To: <2390389.thI8mIvbv5@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On Sat, Jun 20, 2015 at 2:33 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Printing IRQ # using "%x" and "%u" unsigned formats isn't quite correct as
> 'ndev->irq' is of  type *int*, so  the "%d" format  needs to be used instead.
>
> While fixing this, beautify the dev_info() message in rcar_can_probe() a bit.

If you change the message, why don't you make it consistent
("interrupt" vs. "IRQ")?

> Fixes: fd1159318e55 ("can: add Renesas R-Car CAN driver")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> ---
>  drivers/net/can/rcar_can.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> Index: linux-can/drivers/net/can/rcar_can.c
> ===================================================================
> --- linux-can.orig/drivers/net/can/rcar_can.c
> +++ linux-can/drivers/net/can/rcar_can.c
> @@ -526,7 +526,7 @@ static int rcar_can_open(struct net_devi
>         napi_enable(&priv->napi);
>         err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
>         if (err) {
> -               netdev_err(ndev, "error requesting interrupt %x\n", ndev->irq);
> +               netdev_err(ndev, "error requesting interrupt %d\n", ndev->irq);
>                 goto out_close;
>         }
>         can_led_event(ndev, CAN_LED_EVENT_OPEN);
> @@ -824,7 +824,7 @@ static int rcar_can_probe(struct platfor
>
>         devm_can_led_init(ndev);
>
> -       dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%u)\n",
> +       dev_info(&pdev->dev, "device registered (regs @ %p, IRQ%d)\n",
>                  priv->regs, ndev->irq);

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
