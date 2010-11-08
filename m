From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.37-rc1, patch] gianfar: fix sleep in atomic...
Date: Tue, 9 Nov 2010 00:30:42 +0100
Message-ID: <201011090030.42693.rjw@sisk.pl>
References: <AANLkTimf_mVrRPEcj8qBbYw1iYHfWdeKUNS3Kk-dfhTT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimf_mVrRPEcj8qBbYw1iYHfWdeKUNS3Kk-dfhTT@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, November 02, 2010, Daniel J Blueman wrote:
> Since device_set_wakeup_enable now sleeps, it should not be called
> from a critical section. Since wol_en is not updated elsewhere, we can
> omit the locking entirely.
> 
> Signed-off-by: Daniel J Blueman <daniel.blueman@gmail.com>

Acked-by: Rafael J. Wysocki <rjw@sisk.pl>

> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
> index 5c566eb..e641d7c 100644
> --- a/drivers/net/gianfar_ethtool.c
> +++ b/drivers/net/gianfar_ethtool.c
> @@ -635,10 +635,8 @@ static int gfar_set_wol(struct net_device *dev,
> struct ethtool_wolinfo *wol)
>  	if (wol->wolopts & ~WAKE_MAGIC)
>  		return -EINVAL;
> 
> -	spin_lock_irqsave(&priv->bflock, flags);
>  	priv->wol_en = wol->wolopts & WAKE_MAGIC ? 1 : 0;
>  	device_set_wakeup_enable(&dev->dev, priv->wol_en);
> -	spin_unlock_irqrestore(&priv->bflock, flags);
> 
>  	return 0;
>  }
> 
