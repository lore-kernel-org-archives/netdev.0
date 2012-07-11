From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 5/9] net/eipoib: Add ethtool file support
Date: Wed, 11 Jul 2012 11:40:05 +0300
Message-ID: <4FFD3BE5.2070508@mellanox.com>
References: <1341922569-4118-1-git-send-email-ogerlitz@mellanox.com>  <1341922569-4118-6-git-send-email-ogerlitz@mellanox.com> <1341942493.2605.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:33094 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751271Ab2GKIkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 04:40:14 -0400
In-Reply-To: <1341942493.2605.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/10/2012 8:48 PM, Ben Hutchings wrote:
> +static void parent_ethtool_get_drvinfo(struct net_device *parent_dev,
> +				       struct ethtool_drvinfo *drvinfo)
> +{
> +	struct parent *parent = netdev_priv(parent_dev);
> +
> +	if (strlen(DRV_NAME) + strlen(parent->ipoib_main_interface) > 31)
> +		strncpy(drvinfo->driver, "driver name is too long", 32);
> Returning error messages like is stupid; either truncate or WARN.

OK

>
>> +	else
>> +		sprintf(drvinfo->driver, "%s:%s",
>> +			DRV_NAME, parent->ipoib_main_interface);
> Why do you not use the separate driver and bus_info fields?

OK, we'll use the bus info field for placing the name of the PIF



>
>> +static const char parent_strings[][ETH_GSTRING_LEN] = {
>> +	/* public statistics */
>> +	"rx_packets", "tx_packets", "rx_bytes",
>> +	"tx_bytes", "rx_errors", "tx_errors",
>> +	"rx_dropped", "tx_dropped", "multicast",
>> +	"collisions", "rx_length_errors", "rx_over_errors",
>> +	"rx_crc_errors", "rx_frame_errors", "rx_fifo_errors",
>> +	"rx_missed_errors", "tx_aborted_errors", "tx_carrier_errors",
>> +	"tx_fifo_errors", "tx_heartbeat_errors", "tx_window_errors",
>> +#define PUB_STATS_LEN	21
> [...]
>
> This is duplicating the basic netdev statistics that are already available without
> ethtool.  Most of them are completely meaningless for Infiniband, I suspect.

OK, will implement the ndo get stats entry for the basic statistics instead
