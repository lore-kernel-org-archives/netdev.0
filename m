From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/fec: "u32" is more explicit than "unsigned long"
Date: Tue, 27 Aug 2013 14:51:44 -0400 (EDT)
Message-ID: <20130827.145144.478588680902912563.davem@davemloft.net>
References: <20130823094920.GP31293@elgon.mountain>
	<1377261869.3364.3.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, grant.likely@linaro.org,
	rob.herring@calxeda.com, fabio.estevam@freescale.com,
	Frank.Li@freescale.com, jim_baxter@mentor.com,
	B38611@freescale.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, kernel-janitors@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab3H0Svr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 14:51:47 -0400
In-Reply-To: <1377261869.3364.3.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 23 Aug 2013 13:44:29 +0100

> On Fri, 2013-08-23 at 12:49 +0300, Dan Carpenter wrote:
>> tmpaddr[] is a six byte array.  We want to set the first four bytes on
>> the first line and the remaining two on the next line.  The code assumes
>> that "unsigned long" is 32 bits and obviously that's not true on 64 bit
>> arches.  It's better to just use u32 instead.
>> 
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>> ---
>> This is a static checker thing and I can't compile this file.
>> 
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
>> index fdf9307..422b125 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1100,9 +1100,9 @@ static void fec_get_mac(struct net_device *ndev)
>>  	 * 4) FEC mac registers set by bootloader
>>  	 */
>>  	if (!is_valid_ether_addr(iap)) {
>> -		*((unsigned long *) &tmpaddr[0]) =
>> +		*((u32 *) &tmpaddr[0]) =
>>  			be32_to_cpu(readl(fep->hwp + FEC_ADDR_LOW));
>> -		*((unsigned short *) &tmpaddr[4]) =
>> +		*((u16 *) &tmpaddr[4]) =
>>  			be16_to_cpu(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);
>>  		iap = &tmpaddr[0];
>>  	}
> 
> This code also seems to have CPU vs big-endian byte order the wrong way
> round.  readl() returns bytes in native order whereas we always store
> MAC addresses in network (big-endian) order.  So I think it should be
> doing:
> 
> 		*((__be32 *) &tmpaddr[0]) =
> 			cpu_to_be32(readl(fep->hwp + FEC_ADDR_LOW));
> 		*((__be16 *) &tmpaddr[4]) =
> 			cpu_to_be16(readl(fep->hwp + FEC_ADDR_HIGH) >> 16);

Dan please resubmit with Ben's suggested changes, thanks.
