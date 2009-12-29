From: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] usbnet: test off by one
Date: Tue, 29 Dec 2009 15:13:28 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912291504520.2335@fry.nucleusys.com>
References: <4B37D000.6070009@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Petko Manolov <petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4B37D000.6070009-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 	Hey Roel,

MII_TIMEOUT is a number i made up myself, reasonably small so the driver 
won't sit there forever, but higher than 2.  While testing the gadget i 
discovered that reading MII registers sometimes require more than one 
attempt.

Technically you're right.  In practice it doesn't matter much.  Hitting 
the boundary condition mean things are already out of hand.


 		Petko



On Sun, 27 Dec 2009, Roel Kluin wrote:

> With `while (i++ < MII_TIMEOUT)' i reaches MII_TIMEOUT + 1 after the loop
> This is probably unlikely a problem in practice.
>
> Signed-off-by: Roel Kluin <roel.kluin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> drivers/net/usb/rtl8150.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index f14d225..fd19db0 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
> @@ -270,7 +270,7 @@ static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
> 		get_registers(dev, PHYCNT, 1, data);
> 	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
>
> -	if (i < MII_TIMEOUT) {
> +	if (i <= MII_TIMEOUT) {
> 		get_registers(dev, PHYDAT, 2, data);
> 		*reg = data[0] | (data[1] << 8);
> 		return 0;
> @@ -295,7 +295,7 @@ static int write_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 reg)
> 		get_registers(dev, PHYCNT, 1, data);
> 	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
>
> -	if (i < MII_TIMEOUT)
> +	if (i <= MII_TIMEOUT)
> 		return 0;
> 	else
> 		return 1;
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
