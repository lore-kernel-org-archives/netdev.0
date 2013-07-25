From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH V3 net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Thu, 25 Jul 2013 11:00:58 +0300
Message-ID: <1374739258.31118.63.camel@smile>
References: <b04d68ebb04aa2d4ab9392c5353a53c81be7b847.1374728627.git.dvhart@linux.intel.com>
	 <4d6af18d01b977c9db13c3d8052631c97e099ea0.1374728627.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux Net Dev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joe Perches <joe@perches.com>
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45450 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244Ab3GYIBK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 04:01:10 -0400
In-Reply-To: <4d6af18d01b977c9db13c3d8052631c97e099ea0.1374728627.git.dvhart@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 22:10 -0700, Darren Hart wrote: 
> The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> and add a pci_device_id.driver_data structure and functions to handle
> platform setup.
> 
> The AR803x does not implement the RGMII 2ns TX clock delay in the trace
> routing nor via strapping. Add a detection method for the board and the
> PHY and enable the TX clock delay via the registers.
> 
> This PHY will hibernate without link for 10 seconds. Ensure the PHY is
> awake for probe and then disable hibernation. A future improvement would
> be to convert pch_gbe to using PHYLIB and making sure we can wake the
> PHY at the necessary times rather than permanently disabling it.

Couple of nitpicks.

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -582,6 +582,19 @@ struct pch_gbe_hw_stats {
>  };
>  
>  /**
> + * struct pch_gbe_privdata - PCI Device ID driver data
> + * @phy_tx_clk_delay:		Bool, configure the PHY TX delay in software
> + * @phy_disable_hibernate:	Bool, disable PHY hibernation
> + * @platform_init:		Platform initialization callback, called from
> + *				probe, prior to PHY initialization.
> + */
> +struct pch_gbe_privdata {
> +	bool phy_tx_clk_delay;
> +	bool phy_disable_hibernate;
> +	int(*platform_init)(struct pci_dev *pdev);

I think space after "int" will be good.

> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -23,6 +23,8 @@
>  #include <linux/module.h>
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_classify.h>
> +#include <linux/gpio.h>
> +#include <linux/mod_devicetable.h>

You do not need to include that file directly since pci.h includes it,
and pci.h is included via pch_gbe.h.


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
