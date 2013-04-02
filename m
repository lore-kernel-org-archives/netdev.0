From: Frank Li <lznuaa@gmail.com>
Subject: Re: Freescale FEC: fall back to random address
Date: Tue, 2 Apr 2013 16:23:13 +0800
Message-ID: <CAHrpEqSVUc1yedCoyOrRoxkjY7=N_pCDB1F7-WvRaP+4UEY68A@mail.gmail.com>
References: <20130331210605.GA29191@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kernel list <linux-kernel@vger.kernel.org>,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	Frank.Li@freescale.com, netdev@vger.kernel.org
To: Pavel Machek <pavel@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130331210605.GA29191@amd.pavel.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think it is okay.

2013/4/1 Pavel Machek <pavel@denx.de>:
> If there's no valid ethernet address, fall back to randomly generated
> one.
>
> (Yes, I need to get newer u-boot for the board, but as the only
> available one is from 2009... this might be good idea).
>
> Signed-off-by: Pavel Machek <pavel@denx.de>
>
>
> index e3f3937..5a7d1e1 100644
> pp--- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -906,6 +914,16 @@ static void fec_get_mac(struct net_device *ndev)
>                 iap = &tmpaddr[0];
>         }
>
> +       /*
> +        * 5) random mac address
> +        */
> +       if (!is_valid_ether_addr(iap)) {
> +               /* Report it and use a random ethernet address instead */
> +               netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
> +               random_ether_addr(iap);
> +               netdev_info(ndev, "Using random MAC address: %pM\n", iap);
> +       }
> +
>         memcpy(ndev->dev_addr, iap, ETH_ALEN);
>
>         /* Adjust MAC if using macaddr */
>
> --
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
