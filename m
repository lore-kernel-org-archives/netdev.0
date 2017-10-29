From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: Use common error handling code in ravb_probe()
Date: Sun, 29 Oct 2017 12:00:34 +0100
Message-ID: <CAMuHMdXEWpryexcrN7OYcsGfyE3Y_-7Ej2CfgvYgUbZFTTHEWg@mail.gmail.com>
References: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eugeniu Rosca <erosca@de.adit-jv.com>,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>,
        Masaru Nagai <masaru.nagai.vx@renesas.com>,
        =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        Yuval Shaia <yuval.shaia@oracle.com>,
        LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2839c3c2-0116-7549-6ff4-a49eb0a52298@users.sourceforge.net>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Markus,

On Sat, Oct 28, 2017 at 7:19 PM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 28 Oct 2017 19:10:08 +0200
>
> Add a jump target so that a bit of exception handling can be better reused
> at the end of this function.
>
> This issue was detected by using the Coccinelle software.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> ---
>  drivers/net/ethernet/renesas/ravb_main.c | 32 ++++++++++++++++----------------
>  1 file changed, 16 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index a8822a756e08..62dbdf7de6cd 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -2069,10 +2069,9 @@ static int ravb_probe(struct platform_device *pdev)
>                 irq = platform_get_irq_byname(pdev, "ch22");
>         else
>                 irq = platform_get_irq(pdev, 0);
> -       if (irq < 0) {
> -               error = irq;
> -               goto out_release;
> -       }
> +       if (irq < 0)
> +               goto failure_indication;

IMHO, it's really confusing that "irq" contains the error code, not "error".
Especially when jumping to a meaningless label named "failure_indication"
("irq_failure" would be more intuitive).

So I prefer the original code, regardless of the label name.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
