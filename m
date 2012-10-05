From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 02/11] net: axienet: Add ioctl support
Date: Fri, 05 Oct 2012 07:54:33 +0200
Message-ID: <506E7619.3010104@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>  <1349374497-9540-2-git-send-email-monstr@monstr.eu> <1349378262.2817.25.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:41955 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab2JEGrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 02:47:04 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so190869wib.1
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 23:47:03 -0700 (PDT)
In-Reply-To: <1349378262.2817.25.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2012 09:17 PM, Ben Hutchings wrote:
> On Thu, 2012-10-04 at 20:14 +0200, Michal Simek wrote:
>> Allow user to access the MDIO from userspace.
>>
>> Signed-off-by: Michal Simek <monstr@monstr.eu>
>> CC: Anirudha Sarangi <anirudh@xilinx.com>
>> CC: John Linn <John.Linn@xilinx.com>
>> CC: Grant Likely <grant.likely@secretlab.ca>
>> CC: Rob Herring <rob.herring@calxeda.com>
>> CC: David S. Miller <davem@davemloft.net>
>> ---
>>   drivers/net/ethernet/xilinx/xilinx_axienet_main.c |   15 +++++++++++++++
>>   1 files changed, 15 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
>> index 50167ab..a5b41cd 100644
>> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
>> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
>> @@ -1053,6 +1053,20 @@ static void axienet_poll_controller(struct net_device *ndev)
>>   }
>>   #endif
>>
>> +/* Ioctl MII Interface */
>> +static int axienet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
>> +{
>> +	struct axienet_local *priv = netdev_priv(dev);
>> +
>> +	if (!netif_running(dev))
>> +		return -EINVAL;
>
> Not sure this is the appropriate error code.
>
>> +	if (!priv->phy_dev)
>> +		return -ENODEV;
>
> Error code should be EOPNOTSUPP - the device is present but just doesn't
> support MDIO.

ok. Thanks will fix it.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
