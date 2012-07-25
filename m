From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC NET-NEXT PATCH 5/6] e1000e: implement MDI/MDI-X control
Date: Wed, 25 Jul 2012 23:43:59 +0100
Message-ID: <1343256239.5132.150.camel@deadeye.wl.decadent.org.uk>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
	 <20120725180025.9995.5613.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56070 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751206Ab2GYWoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:44:02 -0400
In-Reply-To: <20120725180025.9995.5613.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 11:00 -0700, Jesse Brandeburg wrote:
> some users report issues with link failing when connected to certain
> switches.  This gives the user the ability to control the MDI state
> from the driver, allowing users to work around some improperly
> behaving switches.
> 
> forcing in this driver is for now only allowed when auto-neg is
> enabled.
[...]
> --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
[...] 
> @@ -241,6 +246,10 @@ static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
>  	default:
>  		goto err_inval;
>  	}
> +
> +	/* clear MDI, MDI(-X) override is only allowed when autoneg enabled */
> +	adapter->hw.phy.mdix = AUTO_ALL_MODES;
> +
[...]

I have the same question about this assignment as in e1000.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
