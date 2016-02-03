From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] of: of_mdio: Add marvell,88e1145 to whitelist of PHY
 compatibilities.
Date: Wed, 3 Feb 2016 12:14:05 -0800
Message-ID: <56B25F8D.6070809@caviumnetworks.com>
References: <1454528129-6144-1-git-send-email-aaro.koskinen@iki.fi> <20160203200857.GA10262@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0078.outbound.protection.outlook.com ([65.55.169.78]:9680
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933306AbcBCUrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 15:47:14 -0500
In-Reply-To: <20160203200857.GA10262@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 12:08 PM, Andrew Lunn wrote:
> On Wed, Feb 03, 2016 at 09:35:29PM +0200, Aaro Koskinen wrote:
>> Commit ae461131960b ("of: of_mdio: Add a whitelist of PHY
>> compatibilities.") missed one compatible string used in in-tree DTBs:
>> in OCTEON, for selected boards, the kernel DTB pruning code will overwrite
>> the DTB compatible string with "marvell,88e1145", which is missing
>> from the whitelist. Add it.
>
> Does this overwriting means this compatibility is not visible in the
> current DTS files? Or did i miss it?
>
> At least for the Marvell SoCs i intend to submit a patch removing
> these compatible strings from the DTS files. Will you do the same for
> the OCTEON boards?


The compatibility strings may be present in deployed firmware, they 
cannot be removed.  For many OCTEON boards, the device tree is a 
firmware-kernel ABI, it is not practical to unilaterally decide to 
change the bindings on the kernel side as you don't control the firmware.

David Daney

>
>> The patch fixes broken networking on EdgeRouter Lite.
>>
>> Fixes: ae461131960b ("of: of_mdio: Add a whitelist of PHY compatibilities.")
>> Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>
> Thanks
> 	Andrew
>
>> ---
>>   drivers/of/of_mdio.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>> index 5648317..39c4be4 100644
>> --- a/drivers/of/of_mdio.c
>> +++ b/drivers/of/of_mdio.c
>> @@ -154,6 +154,7 @@ static const struct of_device_id whitelist_phys[] = {
>>   	{ .compatible = "marvell,88E1111", },
>>   	{ .compatible = "marvell,88e1116", },
>>   	{ .compatible = "marvell,88e1118", },
>> +	{ .compatible = "marvell,88e1145", },
>>   	{ .compatible = "marvell,88e1149r", },
>>   	{ .compatible = "marvell,88e1310", },
>>   	{ .compatible = "marvell,88E1510", },
>> --
>> 2.4.0
>>
