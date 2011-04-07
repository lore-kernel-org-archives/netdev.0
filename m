From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Thu, 7 Apr 2011 07:35:15 -0700
Message-ID: <20110407143515.GC26452@angua.secretlab.ca>
References: <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
 <20110405030428.GB29522@ponder.secretlab.ca>
 <20110406152322.GA2757@sortiz-mobl>
 <20110406155805.GA20095@suse.de>
 <20110406170537.GB2757@sortiz-mobl>
 <20110406175647.GA8048@suse.de>
 <20110406184733.GD2757@sortiz-mobl>
 <20110406185902.GN25654@legolas.emea.dhcp.ti.com>
 <20110407133717.GA3923@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Felipe Balbi <balbi@ti.com>, Greg KH <gregkh@suse.de>,
	Andres Salomon <dilinger@queued.net>,
	linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110407133717.GA3923@sortiz-mobl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2011 at 03:40:23PM +0200, Samuel Ortiz wrote:
> Hi Felipe,
> 
> On Wed, Apr 06, 2011 at 09:59:02PM +0300, Felipe Balbi wrote:
> > Hi,
> > 
> > On Wed, Apr 06, 2011 at 08:47:34PM +0200, Samuel Ortiz wrote:
> > > > > > What is a "MFD cell pointer" and why is it needed in struct device?
> > > > > An MFD cell is an MFD instantiated device.
> > > > > MFD (Multi Function Device) drivers instantiate platform devices. Those
> > > > > devices drivers sometimes need a platform data pointer, sometimes an MFD
> > > > > specific pointer, and sometimes both. Also, some of those drivers have been
> > > > > implemented as MFD sub drivers, while others know nothing about MFD and just
> > > > > expect a plain platform_data pointer.
> > > > 
> > > > That sounds like a bug in those drivers, why not fix them to properly
> > > > pass in the correct pointer?
> > > Because they're drivers for generic IPs, not MFD ones. By forcing them to use
> > > MFD specific structure and APIs, we make it more difficult for platform code
> > > to instantiate them.
> > 
> > I agree. What I do on those cases is to have a simple platform_device
> > for the core IP driver and use platform_device_id tables to do runtime
> > checks of the small differences. If one platform X doesn't use a
> > platform_bus, it uses e.g. PCI, then you make a PCI "bridge" which
> > allocates a platform_device with the correct name and adds that to the
> > driver model.
> I see, thanks.
> Below is a patch for the Xilinx SPI example. Although this would fix the
> issue, we'd still have to do that on device per device basis. I had a similar
> solution where MFD drivers would set a flag for sub drivers that don't need
> any of the MFD bits. In that case the MFD core code would just forward the
> platform data, instead of embedding it through an MFD cell.

platform_data is already a fiddly bit where you don't know what
structure type platform_data points at; it is implicitly known and
easy to get wrong.  This solution makes me *very* nervous
because it would become even easier to get a mismatch on the
platform_data pointer type.

g.

> 
> Cheers,
> Samuel.
> 
> ---
>  drivers/mfd/timberdale.c |    8 ++++----
>  drivers/spi/xilinx_spi.c |   19 ++++++++++++++++++-
>  include/linux/mfd/core.h |    3 +++
>  3 files changed, 25 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/mfd/timberdale.c b/drivers/mfd/timberdale.c
> index 94c6c8a..c9220ce 100644
> --- a/drivers/mfd/timberdale.c
> +++ b/drivers/mfd/timberdale.c
> @@ -416,7 +416,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg0[] = {
>  		.mfd_data = &timberdale_radio_platform_data,
>  	},
>  	{
> -		.name = "xilinx_spi",
> +		.name = "mfd_xilinx_spi",
>  		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
>  		.resources = timberdale_spi_resources,
>  		.mfd_data = &timberdale_xspi_platform_data,
> @@ -476,7 +476,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg1[] = {
>  		.mfd_data = &timberdale_radio_platform_data,
>  	},
>  	{
> -		.name = "xilinx_spi",
> +		.name = "mfd_xilinx_spi",
>  		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
>  		.resources = timberdale_spi_resources,
>  		.mfd_data = &timberdale_xspi_platform_data,
> @@ -526,7 +526,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg2[] = {
>  		.mfd_data = &timberdale_radio_platform_data,
>  	},
>  	{
> -		.name = "xilinx_spi",
> +		.name = "mfd_xilinx_spi",
>  		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
>  		.resources = timberdale_spi_resources,
>  		.mfd_data = &timberdale_xspi_platform_data,
> @@ -570,7 +570,7 @@ static __devinitdata struct mfd_cell timberdale_cells_bar0_cfg3[] = {
>  		.mfd_data = &timberdale_radio_platform_data,
>  	},
>  	{
> -		.name = "xilinx_spi",
> +		.name = "mfd_xilinx_spi",
>  		.num_resources = ARRAY_SIZE(timberdale_spi_resources),
>  		.resources = timberdale_spi_resources,
>  		.mfd_data = &timberdale_xspi_platform_data,
> diff --git a/drivers/spi/xilinx_spi.c b/drivers/spi/xilinx_spi.c
> index c69c6f2..3287b84 100644
> --- a/drivers/spi/xilinx_spi.c
> +++ b/drivers/spi/xilinx_spi.c
> @@ -471,7 +471,11 @@ static int __devinit xilinx_spi_probe(struct platform_device *dev)
>  	struct spi_master *master;
>  	u8 i;
>  
> -	pdata = mfd_get_data(dev);
> +	if (platform_get_device_id(dev) &&
> +	    platform_get_device_id(dev)->driver_data & MFD_PLATFORM_DEVICE)
> +		pdata = mfd_get_data(dev);
> +	else
> +		pdata = dev->dev.platform_data;
>  	if (pdata) {
>  		num_cs = pdata->num_chipselect;
>  		little_endian = pdata->little_endian;
> @@ -530,6 +534,18 @@ static int __devexit xilinx_spi_remove(struct platform_device *dev)
>  /* work with hotplug and coldplug */
>  MODULE_ALIAS("platform:" XILINX_SPI_NAME);
>  
> +static const struct platform_device_id xilinx_spi_id_table[] = {
> +	{
> +		.name	= XILINX_SPI_NAME,
> +	},
> +	{
> +		.name	= "mfd_xilinx_spi",
> +		.driver_data = MFD_PLATFORM_DEVICE,
> +	},
> +	{  },	/* Terminating Entry */
> +};
> +MODULE_DEVICE_TABLE(platform, xilinx_spi_id_table);
> +
>  static struct platform_driver xilinx_spi_driver = {
>  	.probe = xilinx_spi_probe,
>  	.remove = __devexit_p(xilinx_spi_remove),
> @@ -538,6 +554,7 @@ static struct platform_driver xilinx_spi_driver = {
>  		.owner = THIS_MODULE,
>  		.of_match_table = xilinx_spi_of_match,
>  	},
> +	.id_table	= xilinx_spi_id_table,
>  };
>  
>  static int __init xilinx_spi_pltfm_init(void)
> diff --git a/include/linux/mfd/core.h b/include/linux/mfd/core.h
> index ad1b19a..13f31f4 100644
> --- a/include/linux/mfd/core.h
> +++ b/include/linux/mfd/core.h
> @@ -89,6 +89,9 @@ static inline const struct mfd_cell *mfd_get_cell(struct platform_device *pdev)
>  	return pdev->dev.platform_data;
>  }
>  
> +/* */
> +#define MFD_PLATFORM_DEVICE BIT(0)
> +
>  /*
>   * Given a platform device that's been created by mfd_add_devices(), fetch
>   * the .mfd_data entry from the mfd_cell that created it.
> 
> 
> -- 
> Intel Open Source Technology Centre
> http://oss.intel.com/
