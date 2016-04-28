From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_mdio: Set of_node in the mdio bus
Date: Thu, 28 Apr 2016 17:48:23 -0400 (EDT)
Message-ID: <20160428.174823.1730461951458323563.davem@davemloft.net>
References: <1461595571-11438-1-git-send-email-Linux.HWI@garmin.com>
	<20160428.154410.1087934312951322476.davem@davemloft.net>
	<57228318.90600@garmin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Grygorii.Strashko@linaro.org, jay.schroeder@garmin.com,
	ben.mccauley@garmin.com
To: Linux.HWI@garmin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42772 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbcD1VsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:48:25 -0400
In-Reply-To: <57228318.90600@garmin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "J.D. Schroeder" <Linux.HWI@garmin.com>
Date: Thu, 28 Apr 2016 16:39:36 -0500

> On 04/28/2016 02:44 PM, David Miller wrote:
>>> --- a/drivers/net/ethernet/ti/davinci_mdio.c
>>> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
>>> @@ -343,6 +343,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>>>  		if (davinci_mdio_probe_dt(&data->pdata, pdev))
>>>  			data->pdata = default_pdata;
>>>  		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
>>> +		data->bus->dev.of_node = dev->of_node;
>>>  	} else {
>>>  		data->pdata = pdata ? (*pdata) : default_pdata;
>>>  		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",
>> 
>> You can't do this.
>> 
>> First of all, of_node objects are reference counted.  So even if this was a
>> legal thing to do you would have to drop the reference to the existing of_node
>> pointer and gain a reference to dev->of_node.
>> 
>> But even more importantly, it is the job of the bus driver to set that
>> bus->dev.of_node correctly, you should never override it in a driver like
>> this.
> 
> David, thanks for your review. I understand your point about the reference count.
> 
> One thing to note is that it is always null for the davinci mdio bus when
> going through this path. I'm not trying to override it. I'm trying to make
> sure it has a way to find the davinci mdio bus. Do you see the problem I'm
> trying to solve?
> 
> Is there another way to be able to make the of_mdio_find_bus() call be able to
> find the davinci mdio bus?

You should reference the device which actually has an OF node attached with it,
rather than pretending that the MDIO bus does.

Don't fake this stuff, reference the proper device to get the OF node.

Thanks.
