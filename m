From: Peter Chen <peter.chen@nxp.com>
Subject: RE: [PATCH 14/15] ethernet: stmicro: stmmac: stmmac_platform: add
 missing of_node_put after calling of_parse_phandle
Date: Mon, 1 Aug 2016 06:50:23 +0000
Message-ID: <HE1PR04MB14502794E6B557099BD55D348B040@HE1PR04MB1450.eurprd04.prod.outlook.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-15-git-send-email-peter.chen@nxp.com>
 <5799B6BD.6010304@st.com>
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
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"wxt@rock-chips.com" <wxt@rock-chips.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"david.daney@cavium.com" <david.daney@cavium.com>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"jszhang@marvell.com" <jszhang@marvell.com>
To: Alexandre Torgue <alexandre.torgue@st.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0046.outbound.protection.outlook.com ([104.47.1.46]:56000
	"EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752906AbcHAL0J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2016 07:26:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>
>>Hi,
>>
>>On 07/27/2016 04:20 AM, Peter Chen wrote:
>>> of_node_put needs to be called when the device node which is got from
>>> of_parse_phandle has finished using.
>>>
>>> Signed-off-by: Peter Chen <peter.chen@nxp.com>
>>> ---
>>>   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 5 ++++-
>>>   1 file changed, 4 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> index f7dfc0a..8d88782 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> @@ -113,8 +113,10 @@ static struct stmmac_axi
>>> *stmmac_axi_setup(struct
>>platform_device *pdev)
>>>   		return NULL;
>>>
>>>   	axi = kzalloc(sizeof(*axi), GFP_KERNEL);
>>> -	if (!axi)
>>> +	if (!axi) {
>>> +		of_node_put(np);
>>>   		return ERR_PTR(-ENOMEM);
>>> +	}
>>>
>>>   	axi->axi_lpi_en = of_property_read_bool(np, "snps,lpi_en");
>>>   	axi->axi_xit_frm = of_property_read_bool(np, "snps,xit_frm"); @@
>>> -127,6 +129,7 @@ static struct stmmac_axi *stmmac_axi_setup(struct
>>platform_device *pdev)
>>>   	of_property_read_u32(np, "snps,wr_osr_lmt", &axi->axi_wr_osr_lmt);
>>>   	of_property_read_u32(np, "snps,rd_osr_lmt", &axi->axi_rd_osr_lmt);
>>>   	of_property_read_u32_array(np, "snps,blen", axi->axi_blen,
>>> AXI_BLEN);
>>> +	of_node_put(np);
>>>
>>>   	return axi;
>>>   }
>>>
>>
>>I agree with the modification inside stmmac_axi. I just have a question
>>about np =
>>pdev->dev.of_node inside stmmac_probe_config_dt (same file).
>>We could add a "of_node_put(np)" just before "return plat" ?
>>
>
>Yes, you remind me there is still one node need to be put (should be plat->phy_node),
>except for changing node name at error path, how about calling of_node_put(plat-
>>phy_node) at stmmac_release after phy is disconnected?
>

Since the plat->phy_node will be used during the whole life cycle, I put it at
stmmac_dvr_remove at my v2 patch set.

Best regards,
Peter
