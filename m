From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] can: flexcan: use be32_to_cpup to handle the value of dt entry
Date: Wed, 27 Jun 2012 19:26:07 +0800
Message-ID: <CAAQ0ZWT3ovG7eKZZuoSZkx4FGd+W9XvnTk8R1yuD02u4wqGNHQ@mail.gmail.com>
References: <1340789236-28266-1-git-send-email-mkl@pengutronix.de>
	<1340789236-28266-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Hui Wang <jason77.wang@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340789236-28266-2-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27 June 2012 17:27, Marc Kleine-Budde <mkl@pengutronix.de> wrote:
> From: Hui Wang <jason77.wang@gmail.com>
>
> The freescale arm i.MX series platform can support this driver, and
> usually the arm cpu works in the little endian mode by default, while
> device tree entry value is stored in big endian format, we should use
> be32_to_cpup() to handle them, after modification, it can work well
> both on the le cpu and be cpu.
>
I'm wondering if you want to just use of_property_read_u32() to make
it a little bit easier.

Regards,
Shawn

> Cc: stable <stable@vger.kernel.org> # v3.2+
> Cc: Shawn Guo <shawn.guo@linaro.org>
> Signed-off-by: Hui Wang <jason77.wang@gmail.com>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
> =A0drivers/net/can/flexcan.c | =A0 =A04 ++--
> =A01 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index 38c0690..81d4741 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -939,12 +939,12 @@ static int __devinit flexcan_probe(struct platf=
orm_device *pdev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return PTR_ERR(pinctrl);
>
> =A0 =A0 =A0 =A0if (pdev->dev.of_node) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 const u32 *clock_freq_p;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const __be32 *clock_freq_p;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0clock_freq_p =3D of_get_property(pdev-=
>dev.of_node,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0"clock-frequency", NULL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (clock_freq_p)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock_freq =3D *clock_f=
req_p;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 clock_freq =3D be32_to_=
cpup(clock_freq_p);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (!clock_freq) {
> --
> 1.7.10
>
