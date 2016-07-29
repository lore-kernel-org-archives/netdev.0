From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 15/15] ethernet: ti: davinci_emac: add missing of_node_put
 after calling of_parse_phandle
Date: Fri, 29 Jul 2016 14:59:46 +0530
Message-ID: <1c3c541a-a183-4b23-da69-991e48a06184@ti.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-16-git-send-email-peter.chen@nxp.com>
 <cc2ab963-3d26-78d7-2119-bc00bcbbd1c7@ti.com>
 <HE1PR04MB145066B58D8B26F0E4CADA488B0F0@HE1PR04MB1450.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
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
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"wxt@rock-chips.com" <wxt@rock-chips.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"david.daney@cavium.com" <david.daney@cavium.com>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"jszhang@marvell.com" <jszhang@marvell.com>,
	Linux OMAP Mailing List <linux-omap@vger.ker
To: Peter Chen <peter.chen@nxp.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([198.47.19.12]:51892 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbcG2Jad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 05:30:33 -0400
In-Reply-To: <HE1PR04MB145066B58D8B26F0E4CADA488B0F0@HE1PR04MB1450.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Linux Omap ML

On Wednesday 27 July 2016 01:13 PM, Peter Chen wrote:
>  
>> On Wednesday 27 July 2016 07:50 AM, Peter Chen wrote:
>>> of_node_put needs to be called when the device node which is got from
>>> of_parse_phandle has finished using.
>>>
>>> Signed-off-by: Peter Chen <peter.chen@nxp.com>
>>> ---
>>>  drivers/net/ethernet/ti/davinci_emac.c | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/drivers/net/ethernet/ti/davinci_emac.c
>>> b/drivers/net/ethernet/ti/davinci_emac.c
>>> index c6c5465..d8cb9d0 100644
>>> --- a/drivers/net/ethernet/ti/davinci_emac.c
>>> +++ b/drivers/net/ethernet/ti/davinci_emac.c
>>> @@ -1571,6 +1571,7 @@ static int emac_dev_open(struct net_device *ndev)
>>>  	if (priv->phy_node) {
>>>  		phydev = of_phy_connect(ndev, priv->phy_node,
>>>  					&emac_adjust_link, 0, 0);
>>> +		of_node_put(priv->phy_node);
>>>  		if (!phydev) {
>>>  			dev_err(emac_dev, "could not connect to phy %s\n",
>>>  				priv->phy_node->full_name);
>>>
>>
>> phy_node is accessed in case of of_phy_connect() returns error, so it has to be
>> moved after the dev_err log
>>
> 
> Yeah, you are right. I will change it, thanks.
> 

I see one more problem, when you stop and open the interface there is no
way to get the phy_node and interface will be unusable, so of_node_put()
should be moved to remove()

Regards
Mugunthan V N
