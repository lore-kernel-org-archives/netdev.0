From: Wolfram Sang <wsa@sang-engineering.com>
Subject: Re: [can-next PATCH 1/1] net: can: =?UTF-8?Q?c=5Fcan=5Fplatform?=
 =?UTF-8?Q?=3A=20Use=20devm=5Fioremap=20instead=20of=20devm=5Fioremap=5Fre?=
 =?UTF-8?Q?source=2E?=
Date: Fri, 25 Jul 2014 12:49:25 +0200
Message-ID: <4a97162dedd6ab064e83c52757f2ce42@mail.zeus03.de>
References: <1406269181-4092-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Pavel Machek <pavel@denx.de>, Thor Thayer <tthayer@altera.com>,
	Prabhakar Lad <prabhakar.csengg@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Chen Gang <gang.chen@asianux.com>,
	George Cherian <george.cherian@ti.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1406269181-4092-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 25-07-2014 08:19, schrieb Mugunthan V N:
> From: George Cherian <george.cherian@ti.com>
> 
> The raminit register is shared register for both can0 and can1.
> Using devm_ioremap_resource fails the mapping for can1 interface
> leading to a non functional can interface.
> 
> Signed-off-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

The patch is a hack, or? It simply works because we drop all sanity 
checking on the resource.

I am on holiday and can't really check, yet I believe the AM335x has 
devicetree support for accessing single bits in SYSCONF. This is what 
needs to be applied here, too, AFAICT.

> ---
>  drivers/net/can/c_can/c_can_platform.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/can/c_can/c_can_platform.c
> b/drivers/net/can/c_can/c_can_platform.c
> index e29b6d0..5dede6e 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -278,7 +278,8 @@ static int c_can_plat_probe(struct platform_device 
> *pdev)
>  			break;
>  		}
> 
> -		priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
> +		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
> +						     resource_size(res));
>  		if (IS_ERR(priv->raminit_ctrlreg) || priv->instance < 0)
>  			dev_info(&pdev->dev, "control memory is not used for raminit\n");
>  		else
