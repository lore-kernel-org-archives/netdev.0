From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Fri, 12 Jul 2013 22:52:46 -0700
Message-ID: <1373694766.3475.98.camel@envy.home>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
	 <1373677813.2614.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1373677813.2614.23.camel@joe-AO722>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 18:10 -0700, Joe Perches wrote:
> On Fri, 2013-07-12 at 17:58 -0700, Darren Hart wrote:
> > The MinnowBoard uses an AR803x PHY with the PCH GBE which requires
> > special handling. Use the MinnowBoard PCI Subsystem ID to detect this
> > and add a pci_device_id.driver_data structure and functions to handle
> > platform setup.
> 
> trivial comments only:
> 
> Please use scripts/checkpatch.pl

Always good advice. I did actually do that. Some of the reports
conflict with existing formatting throughout the file. I opted for
consistency.

The others.... sigh, I did a last minute cleanup and somehow introduced
the whitespace errors. I do know better and should have waited until
tonight instead of sending them out when I was rushed. Apologies.

Fixed in V3 and awaiting additional feedback.

> 
> []
> 
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c[]
> []
> > +static int pch_gbe_minnow_platform_init(struct pci_dev *pdev)
> []
> > +	if (ret){
> 
> Missing space before brace

Fixed.

> 
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> []
> > +int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw)
> []
> > +	case PHY_AR803X_ID:
> > +		netdev_dbg(adapter->netdev,
> > +			   "Configuring AR803X PHY for 2ns TX clock delay\n"); 
> []
> > +		netdev_err(adapter->netdev,
> > +			   "Unknown PHY (%x), could not set TX clock delay.\n",
> > +			   hw->phy.id);
> []
> > +		netdev_err(adapter->netdev,
> > +			   "Could not configure tx clock delay for PHY.\n");
> []
> > +int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw)
> []
> > +	case PHY_AR803X_ID:
> > +		netdev_dbg(adapter->netdev,
> > +			   "Disabling hibernation for AR803X PHY\n");
> 
> It'd be nice if no period before newline were used
> everywhere.

Indeed, fixed.

Thank you for the review.

> 
> > +		netdev_err(adapter->netdev,
> > +			   "Unknown PHY (%x), could not disable hibernation\n",
> > +			   hw->phy.id);
> []
> > +		netdev_err(adapter->netdev,
> > +			   "Could not disable PHY hibernation.\n");
> 
> 

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
