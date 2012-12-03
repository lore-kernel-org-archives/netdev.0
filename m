From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/3] net: cpsw: verify correct number of slaves in DT
Date: Mon, 3 Dec 2012 22:30:18 +0530
Message-ID: <50BCDAA2.5020308@ti.com>
References: <1354542569-6165-1-git-send-email-jlu@pengutronix.de> <1354542569-6165-2-git-send-email-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Jan Luebbe <jlu@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1354542569-6165-2-git-send-email-jlu@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/3/2012 7:19 PM, Jan Luebbe wrote:
> Check that the number of available slaves passed from DT matches the
> value of the "slaves" property in the cpsw node. Otherwise, priv->slaves
> would be the wrong size.
>
> Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   17 +++++++++++++++++
>   1 file changed, 17 insertions(+)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index c0e676a..8de3e92 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -832,6 +832,16 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   		const char *phy_id = NULL;
>   		const void *mac_addr = NULL;
>   
> +		if (!of_device_is_available(slave_node))
> +			continue;
> +
> +		if (i >= data->slaves) {
> +			dev_err(&pdev->dev, "Too many slaves in the DT (> %d).\n",
> +				data->slaves);
> +			ret = -EINVAL;
> +			goto error_ret;
> +		}
> +
>   		if (of_property_read_string(slave_node, "phy_id", &phy_id)) {
>   			dev_err(&pdev->dev, "Missing slave[%d] phy_id property.\n", i);
>   			ret = -EINVAL;
> @@ -861,6 +871,13 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
>   		i++;
>   	}
>   
> +	if (i < data->slaves) {
> +		dev_err(&pdev->dev, "Not enough slaves in the DT (< %d).\n",
> +			data->slaves);
> +		ret = -EINVAL;
> +		goto error_ret;
> +	}
> +
>   	/*
>   	 * Populate all the child nodes here...
>   	 */

The patches look good to me.

Acked-by: Mugunthan V N<mugunthanvnm@ti.com>

Regards
Mugunthan V N

