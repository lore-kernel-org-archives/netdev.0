From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] asix: do not free array priv->mdio->irq
Date: Thu, 3 Mar 2016 15:25:01 +0100
Message-ID: <20160303142501.GF15541@lunn.ch>
References: <1457011676-19042-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457011676-19042-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2016 at 01:27:56PM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Used to be allocated and required freeing, but now
> priv->mdio->irq is now a fixed sized array and should no longer be
> free'd.
> 
> Issue detected using static analysis with CoverityScan
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew

> ---
>  drivers/net/usb/ax88172a.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
> index 224e7d8..cf77f2d 100644
> --- a/drivers/net/usb/ax88172a.c
> +++ b/drivers/net/usb/ax88172a.c
> @@ -134,7 +134,6 @@ static void ax88172a_remove_mdio(struct usbnet *dev)
>  
>  	netdev_info(dev->net, "deregistering mdio bus %s\n", priv->mdio->id);
>  	mdiobus_unregister(priv->mdio);
> -	kfree(priv->mdio->irq);
>  	mdiobus_free(priv->mdio);
>  }
>  
> -- 
> 2.7.0
> 
