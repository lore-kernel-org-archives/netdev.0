From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] phy/at8031: enable at8031 to work on interrupt mode
Date: Thu, 27 Mar 2014 15:52:33 +0400
Message-ID: <53341101.9000404@cogentembedded.com>
References: <1395901116-16034-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	mugunthanvnm@ti.com, zonque@gmail.com, helmut.schaa@googlemail.com,
	R63061@freescale.com
To: Zhao Qiang <B45475@freescale.com>, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, B07421@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395901116-16034-1-git-send-email-B45475@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 27-03-2014 10:18, Zhao Qiang wrote:

> The at8031 can work on polling mode and interrupt mode.
> Add ack_interrupt and config intr funcs to enable
> interrupt mode for it.

> Signed-off-by: Zhao Qiang <B45475@freescale.com>
> ---
>   drivers/net/phy/at803x.c | 30 ++++++++++++++++++++++++++++++
>   1 file changed, 30 insertions(+)

> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index bc71947..d034ef5 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
[...]
> @@ -191,6 +194,31 @@ static int at803x_config_init(struct phy_device *phydev)
>   	return 0;
>   }
>
> +static int at803x_ack_interrupt(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	err = phy_read(phydev, AT803X_INSR);

    Could make this an initializer...

> +
> +	return (err < 0) ? err : 0;
> +}
> +
> +static int at803x_config_intr(struct phy_device *phydev)
> +{
> +	int err;
> +	int value;
> +
> +	value = phy_read(phydev, AT803X_INER);
> +
> +	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
> +		err = phy_write(phydev, AT803X_INER,
> +				(value | AT803X_INER_INIT));

    Inner parens not needed.

> +	else
> +		err = phy_write(phydev, AT803X_INER, value);

    Why are you not clearing the bits here? Why write back what has been read 
at all?

WBR, Sergei
