From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] of_mdio: use IS_ERR_OR_NULL()
Date: Fri, 11 Mar 2016 15:03:31 -0800
Message-ID: <56E34EC3.2000008@gmail.com>
References: <4882738.uyje2ICxKW@wasted.cogentembedded.com>
 <3305414.rAFdOb57tB@wasted.cogentembedded.com> <56E34C56.10300@mleia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Vladimir Zapolskiy <vz@mleia.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	frowand.list@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36739 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932758AbcCKXFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:05:05 -0500
In-Reply-To: <56E34C56.10300@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 14:53, Vladimir Zapolskiy wrote:
> Hello Sergei,
> 
> On 12.03.2016 00:12, Sergei Shtylyov wrote:
>> IS_ERR_OR_NULL() is open coded in of_mdiobus_register_{phy|device}(), so
>> just call it directly...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>>  drivers/of/of_mdio.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> Index: net-next/drivers/of/of_mdio.c
>> ===================================================================
>> --- net-next.orig/drivers/of/of_mdio.c
>> +++ net-next/drivers/of/of_mdio.c
>> @@ -56,7 +56,7 @@ static int of_mdiobus_register_phy(struc
>>  		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>>  	else
>>  		phy = get_phy_device(mdio, addr, is_c45);
>> -	if (!phy || IS_ERR(phy))
>> +	if (IS_ERR_OR_NULL(phy))
>>  		return 1;
>>  
>>  	rc = irq_of_parse_and_map(child, 0);
>> @@ -98,7 +98,7 @@ static int of_mdiobus_register_device(st
>>  	int rc;
>>  
>>  	mdiodev = mdio_device_create(mdio, addr);
>> -	if (!mdiodev || IS_ERR(mdiodev))
>> +	if (IS_ERR_OR_NULL(mdiodev))
>>  		return 1;
>>  
> 
> I don't see how it is possible for mdio_device_create() to return NULL,
> instead of this change consider to remove if (!mdiodev) check.

Good point, worst case we return PTR_ERR(-ENOMEM).
-- 
Florian
