From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 15/15] ethernet: ti: davinci_emac: add missing of_node_put
 after calling of_parse_phandle
Date: Wed, 27 Jul 2016 11:15:25 +0530
Message-ID: <cc2ab963-3d26-78d7-2119-bc00bcbbd1c7@ti.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-16-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vbridger@opensource.altera.com>,
	<isubramanian@apm.com>, <kchudgar@apm.com>,
	<yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <tremyfr@gmail.com>,
	<wxt@rock-chips.com>, <arnd@arndb.de>, <david.daney@cavium.com>,
	<huangdaode@hisilicon.com>, <jszhang@marvell.com>
To: Peter Chen <peter.chen@nxp.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:53735 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758814AbcG0FqG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 01:46:06 -0400
In-Reply-To: <1469586048-15697-16-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 27 July 2016 07:50 AM, Peter Chen wrote:
> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
> 
> Signed-off-by: Peter Chen <peter.chen@nxp.com>
> ---
>  drivers/net/ethernet/ti/davinci_emac.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index c6c5465..d8cb9d0 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1571,6 +1571,7 @@ static int emac_dev_open(struct net_device *ndev)
>  	if (priv->phy_node) {
>  		phydev = of_phy_connect(ndev, priv->phy_node,
>  					&emac_adjust_link, 0, 0);
> +		of_node_put(priv->phy_node);
>  		if (!phydev) {
>  			dev_err(emac_dev, "could not connect to phy %s\n",
>  				priv->phy_node->full_name);
> 

phy_node is accessed in case of of_phy_connect() returns error, so it
has to be moved after the dev_err log

Regards
Mugunthan V N
