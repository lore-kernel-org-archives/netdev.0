From: Prabhakar Lad <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 2/2] net: davinci_mdio: allow to create phys from dt
Date: Wed, 16 Jul 2014 20:23:17 +0100
Message-ID: <CA+V-a8sNcWFdzRws5NkBwwiAb6KymZZHqFLh4Hsqsip3vaRj2g@mail.gmail.com>
References: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
	<1405512783-20307-3-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        dlos
	<davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        Florian Fainelli
	<f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>, netdev
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Rob Herring
	<robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>,
        "David
 S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <1405512783-20307-3-git-send-email-grygorii.strashko-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2014 at 1:13 PM, Grygorii Strashko
<grygorii.strashko-l0cyMroinI0@public.gmane.org> wrote:
> This patch allows to create PHYs from DT in case
> if they are explicitly defined. The of_mdiobus_register() is
> used for such purposes.
>
> For backward compatibility, call  of_mdiobus_register() only in case
> if at least one PHY's child is defined in DT, otherwise rollback to
> mdiobus_register().
>
> Reviewed-by: Santosh Shilimkar <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
> Acked-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> Signed-off-by: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>

Reviewed-by: Lad, Prabhakar <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks,
--Prabhakar Lad

> ---
> Hi Santosh,
>
> I haven't changed style for long-comments, because Networking subsystem
> requires first line of comment not to be empty:
> WARNING:NETWORKING_BLOCK_COMMENT_STYLE: networking block comments don't use an empty /* line, use /* Comment...
>
>  drivers/net/ethernet/ti/davinci_mdio.c |   21 +++++++++++++++++++--
>  1 file changed, 19 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 735dc53..2791f6f 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -38,6 +38,7 @@
>  #include <linux/davinci_emac.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/of_mdio.h>
>  #include <linux/pinctrl/consumer.h>
>
>  /*
> @@ -95,6 +96,10 @@ struct davinci_mdio_data {
>         struct mii_bus  *bus;
>         bool            suspended;
>         unsigned long   access_time; /* jiffies */
> +       /* Indicates that driver shouldn't modify phy_mask in case
> +        * if MDIO bus is registered from DT.
> +        */
> +       bool            skip_scan;
>  };
>
>  static void __davinci_mdio_reset(struct davinci_mdio_data *data)
> @@ -144,6 +149,9 @@ static int davinci_mdio_reset(struct mii_bus *bus)
>         dev_info(data->dev, "davinci mdio revision %d.%d\n",
>                  (ver >> 8) & 0xff, ver & 0xff);
>
> +       if (data->skip_scan)
> +               return 0;
> +
>         /* get phy mask from the alive register */
>         phy_mask = __raw_readl(&data->regs->alive);
>         if (phy_mask) {
> @@ -369,8 +377,17 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>                 goto bail_out;
>         }
>
> -       /* register the mii bus */
> -       ret = mdiobus_register(data->bus);
> +       /* register the mii bus
> +        * Create PHYs from DT only in case if PHY child nodes are explicitly
> +        * defined to support backward compatibility with DTs which assume that
> +        * Davinci MDIO will always scan the bus for PHYs detection.
> +        */
> +       if (dev->of_node && of_get_child_count(dev->of_node)) {
> +               data->skip_scan = true;
> +               ret = of_mdiobus_register(data->bus, dev->of_node);
> +       } else {
> +               ret = mdiobus_register(data->bus);
> +       }
>         if (ret)
>                 goto bail_out;
>
> --
> 1.7.9.5
>
