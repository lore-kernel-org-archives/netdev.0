From: Peter Chen <peter.chen@nxp.com>
Subject: RE: [PATCH 04/15] ethernet: aurora: nb8800: add missing of_node_put
 after calling of_parse_phandle
Date: Mon, 1 Aug 2016 01:19:19 +0000
Message-ID: <HE1PR04MB14502FECE11A0ACF0A1ED0E08B040@HE1PR04MB1450.eurprd04.prod.outlook.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
	<1469586048-15697-5-git-send-email-peter.chen@nxp.com>
 <20160729.231334.379751093388521243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vbridger@opensource.altera.com" <vbridger@opensource.altera.com>,
	"isubramanian@apm.com" <isubramanian@apm.com>,
	"kchudgar@apm.com" <kchudgar@apm.com>,
	"yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
	"salil.mehta@huawei.com" <salil.mehta@huawei.com>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"alexandre.torgue@st.com" <alexandre.torgue@st.com>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"wxt@rock-chips.com" <wxt@rock-chips.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"david.daney@cavium.com" <david.daney@cavium.com>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"jszhang@marvell.com" <jszhang@marvell.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0049.outbound.protection.outlook.com ([104.47.2.49]:40840
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750997AbcHABTw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 21:19:52 -0400
In-Reply-To: <20160729.231334.379751093388521243.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c
>> b/drivers/net/ethernet/aurora/nb8800.c
>> index 0d4ea92..d15d96b 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -1006,6 +1006,7 @@ static int nb8800_stop(struct net_device *dev)
>>
>>  	netif_stop_queue(dev);
>>  	napi_disable(&priv->napi);
>> +	of_node_put(priv->phy_node);
>>
>>  	nb8800_dma_stop(dev);
>>  	nb8800_mac_rx(dev, false);
>
>This is broken.  The priv->phy_node reference is taken in the probe function,
>therefore you have to drop that reference in the "remove" function not the "stop"
>function.
>
>I'm just looking over basic details of this patch series, and along with some other
>feedback you've received, it looks like you really didn't put a lot of auditing into the
>changes you are making.
>
>Please go over this series one more time and resubmit the entire thing after
>everything is sorted out and double-checked.
>

Thanks for your comments, David. I do not familiar with Ethernet driver, and thought
if the node is used up, it can be freed like other drivers. But for phy_node, it will be
used in whole driver's life cycle, it is my careless. I will review each patch in this series
again.

Best regards,
Peter
