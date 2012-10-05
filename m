From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 11/11] net: xilinx: Show csum in bootlog
Date: Fri, 05 Oct 2012 07:48:01 +0200
Message-ID: <506E7491.3000304@monstr.eu>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>  <1349374497-9540-11-git-send-email-monstr@monstr.eu> <1349378144.2817.23.camel@bwh-desktop.uk.solarflarecom.com>
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
Received: from mail-we0-f174.google.com ([74.125.82.174]:44920 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab2JEGwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 02:52:32 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so845671wey.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 23:52:31 -0700 (PDT)
In-Reply-To: <1349378144.2817.23.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2012 09:15 PM, Ben Hutchings wrote:
> On Thu, 2012-10-04 at 20:14 +0200, Michal Simek wrote:
>> Just show current setting in bootlog.
> [...]
>> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
>> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
>> @@ -1052,12 +1052,14 @@ static int __devinit temac_of_probe(struct platform_device *op)
>>   	/* Setup checksum offload, but default to off if not specified */
>>   	lp->temac_features = 0;
>>   	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
>> +	dev_info(&op->dev, "TX_CSUM %d\n", be32_to_cpup(p));
>>   	if (p && be32_to_cpu(*p)) {
>>   		lp->temac_features |= TEMAC_FEATURE_TX_CSUM;
>>   		/* Can checksum TCP/UDP over IPv4. */
>>   		ndev->features |= NETIF_F_IP_CSUM;
>>   	}
>>   	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
>> +	dev_info(&op->dev, "RX_CSUM %d\n", be32_to_cpup(p));
> [...]
>
> Is there any particular reason you think this needs to be logged by
> default, rather than letting users run ethtool -k?  I suggest using
> dev_dbg() instead.

The reason was just to show it in the bootlog.
I will check ethtool support for these drivers.

Thanks for your comments,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
