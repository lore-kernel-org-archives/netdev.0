From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] net: of_mdio: factor out code to parse a phy's
 'reg' property
Date: Tue, 13 May 2014 13:07:38 -0400 (EDT)
Message-ID: <20140513.130738.453141636294063523.davem@davemloft.net>
References: <1399739875-16434-1-git-send-email-zonque@gmail.com>
	<1399739875-16434-2-git-send-email-zonque@gmail.com>
	<536E8C0E.3040407@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org,
	mugunthanvnm@ti.com, ujhelyi.m@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbaEMRHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:07:40 -0400
In-Reply-To: <536E8C0E.3040407@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 11 May 2014 00:29:02 +0400

> Hello.
> 
> On 05/10/2014 08:37 PM, Daniel Mack wrote:
> 
>> Factor out some logic into of_mdio_parse_addr() so it can be reused
>> later.
> 
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> ---
>>   drivers/of/of_mdio.c | 37 +++++++++++++++++++++++++------------
>>   1 file changed, 25 insertions(+), 12 deletions(-)
> 
>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>> index 9a95831..171f9d5 100644
>> --- a/drivers/of/of_mdio.c
>> +++ b/drivers/of/of_mdio.c
>> @@ -114,6 +114,29 @@ static int of_mdiobus_register_phy(struct mii_bus
>> *mdio, struct device_node *chi
>>   	return 0;
>>   }
>>
>> +static int of_mdio_parse_addr(struct device *dev, const struct
>> device_node *np)
>> +{
>> +	const __be32 *paddr;
>> +	u32 addr;
>> +	int len;
>> +
>> +	/* A PHY must have a reg property in the range [0-31] */
>> +	paddr = of_get_property(np, "reg", &len);
>> +	if (!paddr || len < sizeof(*paddr)) {
>> + dev_err(dev, "%s has invalid PHY address\n", np->full_name);
>> +		return -EINVAL;
>> +	}
>> +
>> +	addr = be32_to_cpup(paddr);
> 
>    Why not just use of_property_read_u32() instead of the above? At least
>    that's a material for a follow-up patch...

Agreed, I would prefer if of_property_read_u32() is used here instead
of this by hand expansion.
