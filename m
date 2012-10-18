From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Subject: RE: [PATCH 3/5] net: davinci_mdio: Fix type mistake in calling
 runtime-pm api
Date: Thu, 18 Oct 2012 16:13:43 +0000
Message-ID: <79CD15C6BA57404B839C016229A409A83EB43AE5@DBDE01.ent.ti.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <62191bdcb85ab48f5ea16fe69c2f92aa9e9a0a8b.1350327325.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:44836 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756251Ab2JRQOD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 12:14:03 -0400
In-Reply-To: <62191bdcb85ab48f5ea16fe69c2f92aa9e9a0a8b.1350327325.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 00:46:33, Richard Cochran wrote:
> From: Vaibhav Hiremath <hvaibhav@ti.com>
> 
> By mistake (most likely a copy-paste), instead of pm_runtime_get_sync()
> api, driver is calling pm_runtime_put_sync() api in resume callback
> function. The bug was introduced by commit id (ae2c07aaf74:
> davinci_mdio: runtime PM support).
> 
> Now, the reason why it didn't impact functionality is, the patch has
> been tested on AM335x-EVM and BeagleBone platform while submitting;
> and in case of AM335x the MDIO driver doesn't control the module
> enable/disable part, which is handled by CPSW driver.
> 
> Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>


Thanks for submitting the patches, I couldn't able to do it for almost 2 
weeks now. I really appreciate it.

Thanks,
Vaibhav
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 51a96db..ae74280 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -465,7 +465,7 @@ static int davinci_mdio_resume(struct device *dev)
>  	u32 ctrl;
>  
>  	spin_lock(&data->lock);
> -	pm_runtime_put_sync(data->dev);
> +	pm_runtime_get_sync(data->dev);
>  
>  	/* restart the scan state machine */
>  	ctrl = __raw_readl(&data->regs->control);
> -- 
> 1.7.2.5
> 
> 
