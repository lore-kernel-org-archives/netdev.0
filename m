From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] net: usb: pegasus: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 18 Mar 2017 12:24:13 +0200
Message-ID: <20170318102413.isi5fgq5qwwng2se@p310>
References: <1489790044-11867-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1489790044-11867-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-03-17 23:34:04, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if someone may test this 
> patch.

Yep, the patch seems to be working fine on real hardware.

Acked-by: Petko Manolov <petkan@nucleusys.com>


cheers,
Petko


> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/usb/pegasus.c |   14 ++++++++------
>  1 files changed, 8 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 3667448..321e059 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -953,20 +953,22 @@ static inline void pegasus_reset_wol(struct net_device *dev)
>  }
>  
>  static int
> -pegasus_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
> +pegasus_get_link_ksettings(struct net_device *dev,
> +			   struct ethtool_link_ksettings *ecmd)
>  {
>  	pegasus_t *pegasus;
>  
>  	pegasus = netdev_priv(dev);
> -	mii_ethtool_gset(&pegasus->mii, ecmd);
> +	mii_ethtool_get_link_ksettings(&pegasus->mii, ecmd);
>  	return 0;
>  }
>  
>  static int
> -pegasus_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
> +pegasus_set_link_ksettings(struct net_device *dev,
> +			   const struct ethtool_link_ksettings *ecmd)
>  {
>  	pegasus_t *pegasus = netdev_priv(dev);
> -	return mii_ethtool_sset(&pegasus->mii, ecmd);
> +	return mii_ethtool_set_link_ksettings(&pegasus->mii, ecmd);
>  }
>  
>  static int pegasus_nway_reset(struct net_device *dev)
> @@ -995,14 +997,14 @@ static void pegasus_set_msglevel(struct net_device *dev, u32 v)
>  
>  static const struct ethtool_ops ops = {
>  	.get_drvinfo = pegasus_get_drvinfo,
> -	.get_settings = pegasus_get_settings,
> -	.set_settings = pegasus_set_settings,
>  	.nway_reset = pegasus_nway_reset,
>  	.get_link = pegasus_get_link,
>  	.get_msglevel = pegasus_get_msglevel,
>  	.set_msglevel = pegasus_set_msglevel,
>  	.get_wol = pegasus_get_wol,
>  	.set_wol = pegasus_set_wol,
> +	.get_link_ksettings = pegasus_get_link_ksettings,
> +	.set_link_ksettings = pegasus_set_link_ksettings,
>  };
>  
>  static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
> -- 
> 1.7.4.4
> 
> 
