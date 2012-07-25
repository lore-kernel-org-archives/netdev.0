From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC NET-NEXT PATCH 4/6] e1000: configure and read MDI settings
Date: Wed, 25 Jul 2012 23:41:03 +0100
Message-ID: <1343256063.5132.149.camel@deadeye.wl.decadent.org.uk>
References: <20120725175430.9995.11370.stgit@jbrandeb-snb.jf.intel.com>
	 <20120725180020.9995.32923.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56028 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751206Ab2GYWlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:41:07 -0400
In-Reply-To: <20120725180020.9995.32923.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 11:00 -0700, Jesse Brandeburg wrote:
> this is the implementation in e1000 to allow ethtool to force
> MDI state, allowing users to work around some improperly
> behaving switches.
> 
> forcing in this driver is for now only allowed when auto-neg is enabled.
> 
> to use must have the matching version of ethtool app that supports
> this functionality.
[...]
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -4939,6 +4939,10 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u32 spd, u8 dplx)
>  	default:
>  		goto err_inval;
>  	}
> +
> +	/* clear MDI, MDI(-X) override is only allowed when autoneg enabled */
> +	hw->mdix = AUTO_ALL_MODES;

You will translate AUTO_ALL_MODES to ETH_TP_MDI_AUTO in
e1000_get_settings, and then treat that as an error in
e1000_set_settings if hw->media_type != e1000_media_type_copper.  So,
does this assignment need to be conditional on hw->media_type ==
e1000_media_type_copper?

Ben.

>  	return 0;
>  
>  err_inval:
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
