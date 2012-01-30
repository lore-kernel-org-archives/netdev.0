From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] net: fec: correct phy_name buffer length when init
 phy_name
Date: Mon, 30 Jan 2012 12:07:00 +0100
Message-ID: <4F2679D4.5070404@openwrt.org>
References: <1327910892-11251-1-git-send-email-richard.zhao@linaro.org> <20120130095134.GA11428@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Zhao <richard.zhao@linaro.org>, netdev@vger.kernel.org,
	davem@davemloft.net, u.kleine-koenig@pengutronix.de,
	LW@KARO-electronics.de, linux-arm-kernel@lists.infradead.org,
	patches@linaro.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:36942 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794Ab2A3LHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 06:07:23 -0500
Received: by werb13 with SMTP id b13so3310906wer.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 03:07:22 -0800 (PST)
In-Reply-To: <20120130095134.GA11428@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/30/12 10:51, Shawn Guo wrote:
> On Mon, Jan 30, 2012 at 04:08:12PM +0800, Richard Zhao wrote:
>> Fix the bug that we got wrong phy_name on imx6q sabrelite board.
>> snprintf used wrong length of phy_name.
>> phy_name length is MII_BUS_ID_SIZE + 3 rather not MII_BUS_ID_SIZE.
>> I change it to sizeof(phy_name).
>>
>> Signed-off-by: Richard Zhao<richard.zhao@linaro.org>
>
> Acked-by: Shawn Guo<shawn.guo@linaro.org>
>
> Since this patch fixes a regression seen on v3.3-rc1, it may be
> suitable for -rc series.
>
> The offending commit for the regression would be 391420f
> (fec: use an unique MDIO bus name.) which increases the string
> length of fep->mii_bus->id consequently mdio_bus_id.

Looks good to me since I introduced that "regression", but you already 
had a bug before my patch.

Acked-by: Florian Fainelli <florian@openwrt.org>

>
> Regards,
> Shawn
>
>> ---
>>   drivers/net/ethernet/freescale/fec.c |    2 +-
>>   1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
>> index 7b25e9c..1c7aad8 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -990,7 +990,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
>>   		phy_id = 0;
>>   	}
>>
>> -	snprintf(phy_name, MII_BUS_ID_SIZE, PHY_ID_FMT, mdio_bus_id, phy_id);
>> +	snprintf(phy_name, sizeof(phy_name), PHY_ID_FMT, mdio_bus_id, phy_id);
>>   	phy_dev = phy_connect(ndev, phy_name,&fec_enet_adjust_link, 0,
>>   			      fep->phy_interface);
>>   	if (IS_ERR(phy_dev)) {
>> --
>> 1.7.5.4
>>
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
