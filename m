From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_mdio: Set of_node in the mdio bus
Date: Thu, 28 Apr 2016 15:44:10 -0400 (EDT)
Message-ID: <20160428.154410.1087934312951322476.davem@davemloft.net>
References: <1461595571-11438-1-git-send-email-Linux.HWI@garmin.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Grygorii.Strashko@linaro.org, jay.schroeder@garmin.com,
	ben.mccauley@garmin.com
To: Linux.HWI@garmin.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461595571-11438-1-git-send-email-Linux.HWI@garmin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "J.D. Schroeder" <Linux.HWI@garmin.com>
Date: Mon, 25 Apr 2016 09:46:11 -0500

> From: "J.D. Schroeder" <jay.schroeder@garmin.com>
> 
> Assigns the of_node from the platform device to the of_node of the
> mdio bus so that it can be used in the mdio driver to properly match
> a bus in the DT with a phandle in of_mdio_find_bus().
> 
> Signed-off-by: J.D. Schroeder <jay.schroeder@garmin.com>
> Signed-off-by: Ben McCauley <ben.mccauley@garmin.com>
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 4e7c9b9..b5e5f37 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -343,6 +343,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>  		if (davinci_mdio_probe_dt(&data->pdata, pdev))
>  			data->pdata = default_pdata;
>  		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
> +		data->bus->dev.of_node = dev->of_node;
>  	} else {
>  		data->pdata = pdata ? (*pdata) : default_pdata;
>  		snprintf(data->bus->id, MII_BUS_ID_SIZE, "%s-%x",

You can't do this.

First of all, of_node objects are reference counted.  So even if this was a
legal thing to do you would have to drop the reference to the existing of_node
pointer and gain a reference to dev->of_node.

But even more importantly, it is the job of the bus driver to set that
bus->dev.of_node correctly, you should never override it in a driver like
this.

I'm not applying this, sorry.
