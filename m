From: Li Dongpo <lidongpo@hisilicon.com>
Subject: Re: [PATCH 1/3] net: Add MDIO bus driver for the Hisilicon FEMAC
Date: Tue, 14 Jun 2016 16:24:48 +0800
Message-ID: <575FBF50.30904@hisilicon.com>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <1465798076-176393-2-git-send-email-lidongpo@hisilicon.com>
 <20160613133230.GA3132@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli@gmail.com>, <robh+dt@kernel.org>,
	<mark.rutland@arm.com>, <davem@davemloft.net>,
	<xuejiancheng@hisilicon.com>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:42262 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbcFNIZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 04:25:41 -0400
In-Reply-To: <20160613133230.GA3132@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/6/13 21:32, Andrew Lunn wrote:
> On Mon, Jun 13, 2016 at 02:07:54PM +0800, Dongpo Li wrote:
>> This patch adds a separate driver for the MDIO interface of the
>> Hisilicon Fast Ethernet MAC.
>>
>> Reviewed-by: Jiancheng Xue <xuejiancheng@hisilicon.com>
>> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
>> ---
>>  .../bindings/net/hisilicon-femac-mdio.txt          |  22 +++
>>  drivers/net/phy/Kconfig                            |   8 +
>>  drivers/net/phy/Makefile                           |   1 +
>>  drivers/net/phy/mdio-hisi-femac.c                  | 165 +++++++++++++++++++++
>>  4 files changed, 196 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac-mdio.txt
>>  create mode 100644 drivers/net/phy/mdio-hisi-femac.c

[...]
>> +
> 
> Hi Dongpo
> 
> Overall this looks good. Just some minor comments
> 
>> +static int hisi_femac_mdio_wait_ready(struct mii_bus *bus)
>> +{
>> +	struct hisi_femac_mdio_data *data = bus->priv;
> 
> You could just pass data here. Your read and write functions already
> have it.
> 
Thank you, I will fix it in next patch version.

>> +	data->clk = devm_clk_get(&pdev->dev, NULL);
>> +	if (IS_ERR(data->clk)) {
>> +		ret = -ENODEV;
>> +		goto err_out_free_mdiobus;
>> +	}
> 
> Return the error which devm_clk_get() gives you.
> 
ok, I will fix it.

>> +
>> +	ret = clk_prepare_enable(data->clk);
>> +	if (ret)
>> +		goto err_out_free_mdiobus;
>> +
>> +	ret = of_mdiobus_register(bus, np);
>> +	if (ret)
>> +		goto err_out_free_mdiobus;
> 
> You leave the clock prepared and enabled on error.
> 
ok, I will fix it.

>     Andrew
> 
> .
> 
