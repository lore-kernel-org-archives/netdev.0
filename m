From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: remove phy_disconnect from error path
Date: Thu, 11 Feb 2016 10:39:03 -0500
Message-ID: <8737szi7e0.fsf@ketchup.mtl.sfl>
References: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de> <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Sascha Hauer <s.hauer@pengutronix.de>, narmstrong@baylibre.com
To: Sascha Hauer <s.hauer@pengutronix.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sascha,

Sascha Hauer <s.hauer@pengutronix.de> writes:

> The phy has not been initialized, disconnecting it in the error
> path results in a NULL pointer exception. Drop the phy_disconnect
> from the error path.
>
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> ---
>  net/dsa/slave.c | 1 -
>  1 file changed, 1 deletion(-)
>
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 40b9ca7..91e3b2f 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1194,7 +1194,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>  	if (ret) {
>  		netdev_err(master, "error %d registering interface %s\n",
>  			   ret, slave_dev->name);
> -		phy_disconnect(p->phy);
>  		ds->ports[port] = NULL;
>  		free_netdev(slave_dev);
>  		return ret;

I'm adding Neil in the loop, since he did some work similar to this, if
I'm not mistaken.

Thanks,
-v
