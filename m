From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [RFC][PATCH] ethtool: Add reset operation
Date: Fri, 2 Oct 2009 16:10:12 +0530
Message-ID: <20091002104010.GA19862@serverengines.com>
References: <1254426195.2735.16.camel@achroite>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:1737 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757555AbZJBKkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 06:40:04 -0400
Content-Disposition: inline
In-Reply-To: <1254426195.2735.16.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/09 20:43 +0100, Ben Hutchings wrote:
> After updating firmware stored in flash, users may wish to reset the
> relevant hardware and start the new firmware immediately.  This should
> not be completely automatic as it may be disruptive.
> 
> A selective reset may also be useful for debugging or diagnostics.
> 
> This adds a separate reset operation which takes flags indicating the
> components to be reset.  Drivers are allowed to reset only a subset of
> those requested, and must report the actual subset.  This allows the
> use of generic component masks and some future expansion.
> ---
Looks good. But one question.

> +static int ethtool_reset(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_value reset;
> +	int ret;
> +
> +	if (!dev->ethtool_ops->reset)
> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&reset, useraddr, sizeof(reset)))
> +		return -EFAULT;
> +
> +	ret = dev->ethtool_ops->reset(dev, &reset.data);
> +	if (ret)
> +		return ret;
> +
> +	if (copy_to_user(useraddr, &reset, sizeof(reset)))
> +		return -EFAULT;
Can you tell the intention behind this copy_to_user?
Do you envision drivers sending back some data to the userland - may be
sometime in future?

Thanks
-Ajit
