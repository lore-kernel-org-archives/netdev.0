From: Erez Shitrit <erezsh@mellanox.com>
Subject: Re: [PATCH V2 08/12] net/eipoib: Add ethtool file support
Date: Thu, 2 Aug 2012 11:35:42 +0300
Message-ID: <501A3BDE.1070509@mellanox.com>
References: <1343840975-3252-1-git-send-email-ogerlitz@mellanox.com>  <1343840975-3252-9-git-send-email-ogerlitz@mellanox.com> <1343866955.2602.66.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, Erez Shitrit <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:39122 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750772Ab2HBIfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 04:35:51 -0400
In-Reply-To: <1343866955.2602.66.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/2/2012 3:22 AM, Ben Hutchings wrote:
> On Wed, 2012-08-01 at 20:09 +0300, Or Gerlitz wrote:
>> From: Erez Shitrit <erezsh@mellanox.co.il>
>>
>> Via ethtool the driver describes its version, ABI version, on what PIF
>> interface it runs and various statistics.
> [...]
>> --- /dev/null
>> +++ b/drivers/net/eipoib/eth_ipoib_ethtool.c
> [...]
>> +static void parent_ethtool_get_drvinfo(struct net_device *parent_dev,
>> +				       struct ethtool_drvinfo *drvinfo)
>> +{
>> +	struct parent *parent = netdev_priv(parent_dev);
>> +
>> +	strncpy(drvinfo->driver, DRV_NAME, 32);
>> +
>> +	strncpy(drvinfo->version, DRV_VERSION, 32);
>> +
>> +	strncpy(drvinfo->bus_info, parent->ipoib_main_interface,
>> +		ETHTOOL_BUSINFO_LEN);
> These must be null-terminated; therefore use strlcpy().

ok, will fix.

>> +	/* indicates ABI version */
>> +	snprintf(drvinfo->fw_version, 32, "%d", EIPOIB_ABI_VER);
> [...]
>
> This is an abuse of fw_version.
>
> Ben.
we took the idea from the bonding driver,
(snprintf(drvinfo->fw_version, 32, "%d", BOND_ABI_VERSION);)

Do you have any idea where can we keep the abi version?

Thanks, Erez
