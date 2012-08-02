From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V2 08/12] net/eipoib: Add ethtool file support
Date: Thu, 2 Aug 2012 01:22:35 +0100
Message-ID: <1343866955.2602.66.camel@bwh-desktop.uk.solarflarecom.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>
	 <1343840975-3252-9-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21324 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753116Ab2HBAWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 20:22:39 -0400
In-Reply-To: <1343840975-3252-9-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-08-01 at 20:09 +0300, Or Gerlitz wrote:
> From: Erez Shitrit <erezsh@mellanox.co.il>
> 
> Via ethtool the driver describes its version, ABI version, on what PIF
> interface it runs and various statistics.
[...]
> --- /dev/null
> +++ b/drivers/net/eipoib/eth_ipoib_ethtool.c
[...]
> +static void parent_ethtool_get_drvinfo(struct net_device *parent_dev,
> +				       struct ethtool_drvinfo *drvinfo)
> +{
> +	struct parent *parent = netdev_priv(parent_dev);
> +
> +	strncpy(drvinfo->driver, DRV_NAME, 32);
> +
> +	strncpy(drvinfo->version, DRV_VERSION, 32);
> +
> +	strncpy(drvinfo->bus_info, parent->ipoib_main_interface,
> +		ETHTOOL_BUSINFO_LEN);

These must be null-terminated; therefore use strlcpy().

> +	/* indicates ABI version */
> +	snprintf(drvinfo->fw_version, 32, "%d", EIPOIB_ABI_VER);
[...]

This is an abuse of fw_version.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
