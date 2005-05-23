From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Implement NETDEV_FEAT_CHANGE
Date: Mon, 23 May 2005 09:33:29 -0700
Message-ID: <20050523093329.40617690@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.62.0505201527250.26127@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505201527250.26127@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> --- notify1/net/core/ethtool.c	2005-03-02 09:38:37.000000000 +0200
> +++ linux/net/core/ethtool.c	2005-05-23 11:30:47.000000000 +0300
...
> @@ -712,7 +715,6 @@ int dev_ethtool(struct ifreq *ifr)
>  		break;
>  	case ETHTOOL_GDRVINFO:
>  		rc = ethtool_get_drvinfo(dev, useraddr);
> -
>  		break;

White space creep

>  	case ETHTOOL_GREGS:
>  		rc = ethtool_get_regs(dev, useraddr);
> @@ -801,6 +803,10 @@ int dev_ethtool(struct ifreq *ifr)
>  	
>  	if(dev->ethtool_ops->complete)
>  		dev->ethtool_ops->complete(dev);
> +
> +	if (old_features != dev->features)
> +		netdev_features_change(dev);
> +
>  	return rc;
>  
>   ioctl:

Did you check for any  drivers that don't use ethtool_ops?
