From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/2] net: dsa: remove phy_disconnect from error path
Date: Thu, 11 Feb 2016 16:48:51 +0100
Message-ID: <20160211154851.GA24249@lunn.ch>
References: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
 <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 11, 2016 at 11:44:49AM +0100, Sascha Hauer wrote:
> The phy has not been initialized, disconnecting it in the error
> path results in a NULL pointer exception. Drop the phy_disconnect
> from the error path.
> 
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

Hi Sascha

The fix looks correct, since the phy should be bound to the device in
the following dsa_slave_phy_setup() call.

I'm not sure if Neil also fixed this...

Anyway,

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

     Andrew



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
> -- 
> 2.7.0.rc3
> 
