From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V8 4/7] net: sxgbe: add EEE(Energy Efficient Ethernet)
 for Samsung sxgbe
Date: Fri, 21 Mar 2014 11:04:23 +0000
Message-ID: <20140321110423.GN23372@e106331-lin.cambridge.arm.com>
References: <012f01cf4461$7ac68220$70538660$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev'" <netdev@vger.kernel.org>,
	"linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"'David Miller'" <davem@davemloft.net>,
	"'GIRISH K S'" <ks.giri@samsung.com>,
	"'SIVAREDDY KALLAM'" <siva.kallam@samsung.com>,
	"'Vipul Chandrakant'" <vipul.pandya@samsung.com>,
	"'Ilho Lee'" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <012f01cf4461$7ac68220$70538660$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 20, 2014 at 05:26:06PM +0000, Byungho An wrote:
> From: Girish K S <ks.giri@samsung.com>
> 
> Added support for the EEE(Energy Efficient Ethernet) in 10G ethernet driver.
> 
> Signed-off-by: Girish K S <ks.giri@samsung.com>
> Neatening-by: Joe Perches <joe@perches.com>
> Signed-off-by: Byungho An <bh74.an@samsung.com>
> ---
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h  |   53 +++++++
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_core.c    |   86 +++++++++-
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_ethtool.c |   47 ++++++
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |  165 +++++++++++++++++++-
>  .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    4 +
>  drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h     |    5 +
>  6 files changed, 358 insertions(+), 2 deletions(-)

[...]

> diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
> index e410d84..b23ec57 100644
> --- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
> +++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c
> @@ -160,6 +160,10 @@ static int sxgbe_platform_probe(struct platform_device *pdev)
>                 }
>         }
> 
> +       priv->lpi_irq = irq_of_parse_and_map(dev->of_node, loop++);

You can use platform_get_irq(pdev, loop++) here. The interrupts have
already been parsed elsewhere.

Cheers,
Mark.
