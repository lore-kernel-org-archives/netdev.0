From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ixp4xx_eth: Return proper error for eth_init_one
Date: Thu, 06 Jan 2011 11:11:48 -0800 (PST)
Message-ID: <20110106.111148.189705155.davem@davemloft.net>
References: <1294205046.8294.2.camel@mola>
	<m3bp3vi6v9.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: axel.lin@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m3bp3vi6v9.fsf@intrepid.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Wed, 05 Jan 2011 18:43:22 +0100

> Axel Lin <axel.lin@gmail.com> writes:
> 
>> Return PTR_ERR(port->phydev) instead of 1 if phy_connect failed.
>>
>> Signed-off-by: Axel Lin <axel.lin@gmail.com>
> 
>> --- a/drivers/net/arm/ixp4xx_eth.c
>> +++ b/drivers/net/arm/ixp4xx_eth.c
>> @@ -1229,8 +1229,10 @@ static int __devinit eth_init_one(struct platform_device *pdev)
>>  	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, "0", plat->phy);
>>  	port->phydev = phy_connect(dev, phy_id, &ixp4xx_adjust_link, 0,
>>  				   PHY_INTERFACE_MODE_MII);
>> -	if ((err = IS_ERR(port->phydev)))
>> +	if (IS_ERR(port->phydev)) {
>> +		err = PTR_ERR(port->phydev);
>>  		goto err_free_mem;
>> +	}
>>  
>>  	port->phydev->irq = PHY_POLL;
> 
> Right. Thanks.
> 
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>

I'll apply this, thanks.
