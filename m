From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 3/9] igb: Update firmware info output
Date: Sun, 10 Jun 2012 01:57:34 +0100
Message-ID: <1339289854.21665.161.camel@deadeye.wl.decadent.org.uk>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1339230063-12545-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Carolyn Wyborny <carolyn.wyborny@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8653 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752592Ab2FJA5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 20:57:39 -0400
In-Reply-To: <1339230063-12545-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-09 at 01:20 -0700, Jeff Kirsher wrote:
> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> Our NVM image creation tools have evolved over the years and there are
> multiple versions contained in them, depending on the tool used to create
> them.  This patch outputs the NVM versions available in ethtool -i output.
[...]
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -718,20 +718,16 @@ static void igb_get_drvinfo(struct net_device *netdev,
>  			    struct ethtool_drvinfo *drvinfo)
>  {
>  	struct igb_adapter *adapter = netdev_priv(netdev);
> -	u16 eeprom_data;
>  
>  	strlcpy(drvinfo->driver,  igb_driver_name, sizeof(drvinfo->driver));
>  	strlcpy(drvinfo->version, igb_driver_version, sizeof(drvinfo->version));
>  
> -	/* EEPROM image version # is reported as firmware version # for
> -	 * 82575 controllers */
> -	adapter->hw.nvm.ops.read(&adapter->hw, 5, 1, &eeprom_data);
> -	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
> -		"%d.%d-%d",
> -		(eeprom_data & 0xF000) >> 12,
> -		(eeprom_data & 0x0FF0) >> 4,
> -		eeprom_data & 0x000F);
> -
> +	/*
> +	 * EEPROM image version # is reported as firmware version # for
> +	 * 82575 controllers
> +	 */
> +	strlcpy(drvinfo->fw_version, adapter->fw_version,
> +		sizeof(drvinfo->fw_version));
[...]

Doesn't this driver support online firmware upgrades using
ETHTOOL_SEEPROM?  If so then you should carry on reading the version
from NVRAM here, rather than only doing it at probe time.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
