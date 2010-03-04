From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4] ethtool: Add direct access to ops->get_sset_count
Date: Thu, 04 Mar 2010 14:26:37 +0000
Message-ID: <1267712797.2819.149.camel@localhost>
References: <20100304085054.4471.44679.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3898 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab0CDO0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 09:26:42 -0500
In-Reply-To: <20100304085054.4471.44679.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-03-04 at 00:51 -0800, Jeff Kirsher wrote:
> From: Jeff Garzik <jgarzik@redhat.com>
> 
> This patch is an alternative approach for accessing string
> counts, vs. the drvinfo indirect approach.  This way the drvinfo
> space doesn't run out, and we don't break ABI later.
[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -214,6 +214,10 @@ static noinline int ethtool_get_drvinfo(struct net_device *dev, void __user *use
>  	info.cmd = ETHTOOL_GDRVINFO;
>  	ops->get_drvinfo(dev, &info);
>  
> +	/*
> +	 * this method of obtaining string set info is deprecated;
> +	 * consider using ETHTOOL_GSSET_INFO instead
> +	 */

This comment belongs on the interface (ethtool.h) not the
implementation.

[...]
> +static noinline int ethtool_get_sset_info(struct net_device *dev,
> +                                          void __user *useraddr)
> +{
[...]
> +	/* calculate size of return buffer */
> +	for (i = 0; i < 64; i++)
> +		if (sset_mask & (1ULL << i))
> +			n_bits++;
[...]

We have a function for this:

	n_bits = hweight64(sset_mask);

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

