From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH V2 net-next 2/2] pch_gbe: Add MinnowBoard support
Date: Wed, 24 Jul 2013 17:20:03 -0700
Message-ID: <1374711603.3436.246.camel@dvhart-mobl1.amr.corp.intel.com>
References: <b939bb41630693171771c108801c1c5f688ecabc.1374525261.git.dvhart@linux.intel.com>
	 <cover.1374525261.git.dvhart@linux.intel.com>
	 <79241b53ec4e638008ba3384958ef9901ad11338.1374525261.git.dvhart@linux.intel.com>
	 <20130724.170008.924195436945641752.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hpa@zytor.com,
	peter.p.waskiewicz.jr@intel.com, andriy.shevchenko@linux.intel.com,
	joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55843 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753048Ab3GYAUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jul 2013 20:20:05 -0400
In-Reply-To: <20130724.170008.924195436945641752.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-24 at 17:00 -0700, David Miller wrote:
> From: Darren Hart <dvhart@linux.intel.com>
> Date: Mon, 22 Jul 2013 14:41:59 -0700
> 
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> > index da07907..be513a9 100644
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
>  ...
> > @@ -277,4 +286,91 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
> >       pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
> >       mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
> >       pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
> > +
> > +     /* Setup a TX clock delay on certain platforms */
> > +     if (adapter->pdata && adapter->pdata->phy_tx_clk_delay)
> > +             pch_gbe_phy_tx_clk_delay(hw);
> > +}
> > +
> > +/* pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
> > + * @hw:                  Pointer to the HW structure
> > + * Returns
> > + *   0:              Successful.
> > + *   -EINVAL:        Invalid argument.
> > + */
> > +int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw)
>  ...
> > diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
> > index 03264dc..e3e4bc9 100644
> > --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
> > +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
> > @@ -33,5 +33,7 @@ void pch_gbe_phy_power_up(struct pch_gbe_hw *hw);
> >  void pch_gbe_phy_power_down(struct pch_gbe_hw *hw);
> >  void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw);
> >  void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw);
> > +int pch_gbe_phy_tx_clk_delay(struct pch_gbe_hw *hw);
> > +int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw);
> 
> 
> pch_gbe_phy_tx_clk_delay() is only invoked from pch_gbe_phy.c, where it is also
> implemented.
> 
> Therefore it should be marked static and the declaration removed from
> pch_gbe_phy.h

Ah, thanks. Leftover from a more complex driver_data with pointers to
these functions. I'll fix and resubmit this patch alone as V3.
Otherwise, no objections?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
