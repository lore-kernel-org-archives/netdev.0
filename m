From: <sean.wang@mediatek.com>
Subject: Re: [RESEND PATCH net 09/10] net: ethernet: mediatek: use devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
Date: Fri, 26 Aug 2016 14:33:13 +0800
Message-ID: <1472193193-24046-1-git-send-email-sean.wang@mediatek.com>
References: <84142b03-2100-1d56-8f5e-1d39b1748a25@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>
To: <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:38398 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750766AbcHZGdU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 02:33:20 -0400
In-Reply-To: <84142b03-2100-1d56-8f5e-1d39b1748a25@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Date: Thu, 25 Aug 2016 15:39:08 +0200, John Crispin wrote:
>Hi Sean, >
>small nitpick inline
>
>On 25/08/2016 12:45, Sean Wang wrote:
>> a lot of parts in the driver uses devm_* APIs to gain benefits from the
....
  
>> -	eth->mii_bus = mdiobus_alloc();
>> +	eth->mii_bus = devm_mdiobus_alloc(eth->dev);
>>  	if (!eth->mii_bus) {
>>  		err = -ENOMEM;
>>  		goto err_put_node;
>> @@ -318,18 +318,9 @@ static int mtk_mdio_init(struct mtk_eth *eth)
>>  
>>  	snprintf(eth->mii_bus->id, MII_BUS_ID_SIZE, "%s", mii_np->name);
>>  	err = of_mdiobus_register(eth->mii_bus, mii_np);
>> -	if (err)
>> -		goto err_free_bus;
>> -	of_node_put(mii_np);
>> -
>> -	return 0;
>> -
>> -err_free_bus:
>> -	mdiobus_free(eth->mii_bus);
>>  
>>  err_put_node:
>>  	of_node_put(mii_np);
>> -	eth->mii_bus = NULL;
>>  	return err;
>
>you might want to rename err to ret. that would make it more readable.
>right now it looks like the code always flows through the error path.
>
>	John
>

okay, i will change this from err to ret for readable code
and my thought is using common code provided by the framework helps
to 
1) have simplified the code flow as [1] says 
2) decrease the risk of incorrect error handling by human
3) only a few drivers used it since it ware proposed on linux 3.16,
so just hope to promote for this.

[1] https://patchwork.ozlabs.org/patch/344093/

>>  }
>>  
>> @@ -339,8 +330,6 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
>>  		return;
>>  
>>  	mdiobus_unregister(eth->mii_bus);
>> -	of_node_put(eth->mii_bus->dev.of_node);
>> -	mdiobus_free(eth->mii_bus);
>>  }
