From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] wimax: i2400m - prevent a possible kernel bug due
 to missing fw_name string
Date: Mon, 26 Mar 2012 15:57:10 +0100
Message-ID: <1332773830.3500.88.camel@deadeye>
References: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<inaky.perez-gonzalez@intel.com>
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31759 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932444Ab2CZO5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 10:57:15 -0400
In-Reply-To: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 13:23 +0200, Phil Sutter wrote:
> This happened on a machine with a custom hotplug script calling nameif,
> probably due to slow firmware loading. At the time nameif uses ethtool
> to gather interface information, i2400m->fw_name is zero and so a null
> pointer dereference occurs from within i2400m_get_drvinfo().
> 
> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
> ---
>  drivers/net/wimax/i2400m/netdev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
> index 64a1106..020bd8d 100644
> --- a/drivers/net/wimax/i2400m/netdev.c
> +++ b/drivers/net/wimax/i2400m/netdev.c
> @@ -607,7 +607,8 @@ static void i2400m_get_drvinfo(struct net_device *net_dev,
>  	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
>  
>  	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
> -	strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
> +	strncpy(info->fw_version,
> +	        i2400m->fw_name ? : "N/A", sizeof(info->fw_version) - 1);

Use an empty string, not "N/A".

Ben.

>  	if (net_dev->dev.parent)
>  		strncpy(info->bus_info, dev_name(net_dev->dev.parent),
>  			sizeof(info->bus_info) - 1);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
