From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 08/10] net/macb: macb_get_drvinfo: add GEM/MACB suffix
 to differentiate revision
Date: Thu, 6 Sep 2012 00:27:51 +0100
Message-ID: <1346887671.5325.47.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
	 <fc701a2ed18198b7a671c55f1e65725f1709509c.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<davem@davemloft.net>, <havard@skinnemoen.net>,
	<plagnioj@jcrosoft.com>, <jamie@jamieiles.com>,
	<linux-kernel@vger.kernel.org>, <patrice.vilchez@atmel.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fc701a2ed18198b7a671c55f1e65725f1709509c.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-05 at 11:00 +0200, Nicolas Ferre wrote:
> Add an indication about which revision of the hardware we are running in
> info->driver string.
> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |    4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index bd331fd..c7c39f1 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1313,6 +1313,10 @@ static void macb_get_drvinfo(struct net_device *dev,
>  	struct macb *bp = netdev_priv(dev);
>  
>  	strcpy(info->driver, bp->pdev->dev.driver->name);
> +	if (macb_is_gem(bp))
> +		strcat(info->driver, " GEM");
> +	else
> +		strcat(info->driver, " MACB");
>  	strcpy(info->version, "$Revision: 1.14 $");

Related to hardware revisions (which don't belong here, as David said),
I rather doubt this CVS ID is very useful as a driver version.

If the driver doesn't have a meaningful version (aside from the kernel
version) then you can remove this function and let the ethtool core fill
in the other two fields automatically.

Ben.

>  	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
