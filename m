From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 4/4] net/fec: add imx6q enet support
Date: Mon, 19 Sep 2011 17:08:29 +0800
Message-ID: <20110919090828.GA28084@S2100-06.ap.freescale.net>
References: <1316346852-17090-1-git-send-email-shawn.guo@linaro.org>
 <1316346852-17090-5-git-send-email-shawn.guo@linaro.org>
 <20110918180912.GA3734@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Shawn Guo <shawn.guo@linaro.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <patches@linaro.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:55463
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab1ISI7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 04:59:00 -0400
Content-Disposition: inline
In-Reply-To: <20110918180912.GA3734@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2011 at 08:09:12PM +0200, Francois Romieu wrote:
> Shawn Guo <shawn.guo@linaro.org> :
> [...]
> > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> > index 04206e4..849cb0b 100644
> > --- a/drivers/net/fec.c
> > +++ b/drivers/net/fec.c
> > @@ -442,18 +453,23 @@ fec_restart(struct net_device *ndev, int duplex)
> >  		/* Enable flow control and length check */
> >  		rcntl |= 0x40000000 | 0x00000020;
> >  
> > -		/* MII or RMII */
> > +		/* RGMII, RMII or MII */
> > +		if (fep->phy_interface == PHY_INTERFACE_MODE_RGMII)
> > +			rcntl |= (1 << 6);
> >  		if (fep->phy_interface == PHY_INTERFACE_MODE_RMII)
>            ^^^^ missing "else"
> 
Yes, my bad.

> [...]
> > +		/* 1G, 100M or 10M */
> > +		if (fep->phy_dev) {
> > +			if (fep->phy_dev->speed == SPEED_1000)
> > +				ecntl |= (1 << 8);

Right, this is a typo.  It should be (1 << 5);

> > +			else if (fep->phy_dev->speed == SPEED_100)
> > +				rcntl &= ~(1 << 9);
> > +			else
> > +				rcntl |= (1 << 9);
> > +		}
> [...]
> > +	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
> > +		/* enable ENET endian swap */
> > +		ecntl |= (1 << 8);
> 
> I do not understand why the endian swap bit of ecntl needs to be
> set the same in these two different paths, especially as the latter
> handles the old faulty imx28 and the former the newly fixed imx6q.
> Typo ?
> 
Nice catches.  Thanks a lot, Ueimor.

-- 
Regards,
Shawn
