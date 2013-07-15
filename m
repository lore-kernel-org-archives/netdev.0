From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Mon, 15 Jul 2013 13:55:17 -0700
Message-ID: <1373921717.3475.203.camel@envy.home>
References: <1373677087-7747-1-git-send-email-dvhart@linux.intel.com>
	 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-12 at 17:58 -0700, Darren Hart wrote:
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
> 
> Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: netdev@vger.kernel.org

...

> @@ -277,4 +286,93 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
>  	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
>  	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
>  	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
> +
> +	/* Setup a TX clock delay on certain platforms */
> +	if (adapter->pdata->phy_tx_clk_delay)


This is missing an adapter->pdata !NULL test. Fixed in V3. Holding off
a bit more on that in case Dave M. has anything he wants to see changed
in the next revision.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel
