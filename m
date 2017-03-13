From: Chris Roth <chris.roth-/KKvz3x1pcI@public.gmane.org>
Subject: Re: [PATCH] net: usb: asix88179_178a: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 12 Mar 2017 19:21:27 -0600
Message-ID: <392d4ccd-a335-0078-d95b-2e0d142aa2b9@usask.ca>
References: <1489338156-18632-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <jarod-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489338156-18632-1-git-send-email-tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I can test it tomorrow. I'll pull a clean copy of 4.10.2, or do you
suggest a different version than that?

Chris

On 2017-03-12 11:02 AM, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
>
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
>
> Signed-off-by: Philippe Reynes <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/ax88179_178a.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> index a3a7db0..4a0ae7c 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -620,16 +620,18 @@ static int ax88179_get_eeprom_len(struct net_device *net)
>  	return 0;
>  }
>  
> -static int ax88179_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +static int ax88179_get_link_ksettings(struct net_device *net,
> +				      struct ethtool_link_ksettings *cmd)
>  {
>  	struct usbnet *dev = netdev_priv(net);
> -	return mii_ethtool_gset(&dev->mii, cmd);
> +	return mii_ethtool_get_link_ksettings(&dev->mii, cmd);
>  }
>  
> -static int ax88179_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
> +static int ax88179_set_link_ksettings(struct net_device *net,
> +				      const struct ethtool_link_ksettings *cmd)
>  {
>  	struct usbnet *dev = netdev_priv(net);
> -	return mii_ethtool_sset(&dev->mii, cmd);
> +	return mii_ethtool_set_link_ksettings(&dev->mii, cmd);
>  }
>  
>  static int
> @@ -826,11 +828,11 @@ static int ax88179_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
>  	.set_wol		= ax88179_set_wol,
>  	.get_eeprom_len		= ax88179_get_eeprom_len,
>  	.get_eeprom		= ax88179_get_eeprom,
> -	.get_settings		= ax88179_get_settings,
> -	.set_settings		= ax88179_set_settings,
>  	.get_eee		= ax88179_get_eee,
>  	.set_eee		= ax88179_set_eee,
>  	.nway_reset		= usbnet_nway_reset,
> +	.get_link_ksettings	= ax88179_get_link_ksettings,
> +	.set_link_ksettings	= ax88179_set_link_ksettings,
>  };
>  
>  static void ax88179_set_multicast(struct net_device *net)

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
