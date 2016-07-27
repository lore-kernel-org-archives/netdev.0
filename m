From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 05/15] ethernet: cavium: octeon: add missing of_node_put
 after calling of_parse_phandle
Date: Wed, 27 Jul 2016 13:56:16 -0700
Message-ID: <57991FF0.1010606@caviumnetworks.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com> <1469586048-15697-6-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<vbridger@opensource.altera.com>, <isubramanian@apm.com>,
	<kchudgar@apm.com>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <thomas.petazzoni@free-electrons.com>,
	<sergei.shtylyov@cogentembedded.com>, <peppe.cavallaro@st.com>,
	<alexandre.torgue@st.com>, <mugunthanvnm@ti.com>,
	<tremyfr@gmail.com>, <wxt@rock-chips.com>, <arnd@arndb.de>,
	<david.daney@cavium.com>, <huangdaode@hisilicon.com>,
	<jszhang@marvell.com>
To: Peter Chen <peter.chen@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0073.outbound.protection.outlook.com ([104.47.38.73]:52433
	"EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751849AbcG0V3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2016 17:29:51 -0400
In-Reply-To: <1469586048-15697-6-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2016 07:20 PM, Peter Chen wrote:
> of_node_put needs to be called when the device node which is got
> from of_parse_phandle has finished using.
>
> Signed-off-by: Peter Chen <peter.chen@nxp.com>

NAK.


> ---
>   drivers/net/ethernet/cavium/octeon/octeon_mgmt.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
> index e8bc15b..5eb9d8c 100644
> --- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
> +++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
> @@ -960,6 +960,7 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
>   	phydev = of_phy_connect(netdev, p->phy_np,
>   				octeon_mgmt_adjust_link, 0,
>   				PHY_INTERFACE_MODE_MII);
> +	of_node_put(p->phy_np);

I don't think you can do this here.  octeon_mgmt_init_phy() may be 
called multiple times in the life of the driver, so p->phy_np must 
remain valid.

It may be appropriate to do the  of_node_put() in the 
octeon_mgmt_remove() function.


>
>   	if (!phydev)
>   		return -ENODEV;
>
