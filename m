From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: davinci_mdio: don't request io address range
Date: Fri, 27 Feb 2015 15:55:34 +0000
Message-ID: <CA+V-a8vu6wyzP7wJT8qe_WiKzhtB+jHYH=55fMhAzibJXciRew@mail.gmail.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>, george.cherian@ti.com,
	varkabhadram@gmail.com, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Tony Lindgren <tony@atomide.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	lokeshvutla@ti.com, mpa@pengutronix.de, w-kwok2@ti.com
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 9:27 PM, Murali Karicheri <m-karicheri2@ti.com> wrote:
> From: Grygorii Strashko <grygorii.strashko@ti.com>
>
> Historically Davinci MDIO driver was  created with assumption that
> MDIO is standalone device, but for Keystone 2 it's a part
> of NETCP module and now NETCP driver requests IO range which
> includes MDIO IO range too. This causes Keystone 2 networking stack
> failure during the boot.
>
> "netcp-1.0 2620110.netcp: Probe of module(netcp-gbe) failed with -16"
>
> Hence, don't request io address range from Davinci MDIO driver and
> just remap it.
>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>

Acked-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Cheers,
--Prabhakar Lad

> ---
>  drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 98655b4..b13ec82 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -371,7 +371,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>         spin_lock_init(&data->lock);
>
>         res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -       data->regs = devm_ioremap_resource(dev, res);
> +       data->regs = devm_ioremap_nocache(dev, res->start, resource_size(res));
>         if (IS_ERR(data->regs)) {
>                 ret = PTR_ERR(data->regs);
>                 goto bail_out;
> --
> 1.7.9.5
>
