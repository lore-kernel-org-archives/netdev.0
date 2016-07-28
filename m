From: Peter Chen <peter.chen@nxp.com>
Subject: RE: [PATCH 05/15] ethernet: cavium: octeon: add missing of_node_put
 after calling of_parse_phandle
Date: Thu, 28 Jul 2016 01:57:04 +0000
Message-ID: <HE1PR04MB1450F8C93D0BEF3DAEB35E268B000@HE1PR04MB1450.eurprd04.prod.outlook.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-6-git-send-email-peter.chen@nxp.com>
 <57991FF0.1010606@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0063.outbound.protection.outlook.com ([104.47.2.63]:43328
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753258AbcG1Kbe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 06:31:34 -0400
In-Reply-To: <57991FF0.1010606@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
>
>> ---
>>   drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> index e8bc15b..5eb9d8c 100644
>> --- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> +++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
>> @@ -960,6 +960,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
>>   	phydev = of_phy_connect(netdev, p->phy_np,
>>   				octeon_mgmt_adjust_link, 0,
>>   				PHY_INTERFACE_MODE_MII);
>> +	of_node_put(p->phy_np);
>
>I don't think you can do this here.  octeon_mgmt_init_phy() may be called multiple
>times in the life of the driver, so p->phy_np must remain valid.
>
>It may be appropriate to do the  of_node_put() in the
>octeon_mgmt_remove() function.
 
Thanks, I will change it.

Peter
