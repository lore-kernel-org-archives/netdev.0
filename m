From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 8 Sep 2005 21:08:18 -0400
Message-ID: <20050909010816.GA28653@tuxdriver.com>
References: <200509080125.j881PcL9015847@hera.kernel.org> <431F9899.4060602@pobox.com> <Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de> <1126184700.4805.32.camel@tsc-6.cph.tpack.net> <Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de> <1126190554.4805.68.camel@tsc-6.cph.tpack.net> <Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de> <4320BD96.3060307@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bogdan Costescu <Bogdan.Costescu@iwr.uni-heidelberg.de>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Netdev List <netdev@vger.kernel.org>, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965226AbVIIBMQ@vger.kernel.org>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <4320BD96.3060307@tpack.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2005 at 12:39:18AM +0200, Tommy Christensen wrote:

> --- linux-2.6.13-git8/drivers/net/3c59x.c-orig	Fri Sep  9 00:05:49 2005
> +++ linux-2.6.13-git8/drivers/net/3c59x.c	Fri Sep  9 00:13:55 2005
> @@ -1889,7 +1889,9 @@ vortex_timer(unsigned long data)
>  		{
>  			spin_lock_bh(&vp->lock);
>  			mii_status = mdio_read(dev, vp->phys[0], 1);
> -			mii_status = mdio_read(dev, vp->phys[0], 1);
> +			if (!(mii_status & BMSR_LSTATUS))
> +				/* Re-read to get actual link status */
> +				mii_status = mdio_read(dev, vp->phys[0], 1);
>  			ok = 1;
>  			if (vortex_debug > 2)
>  				printk(KERN_DEBUG "%s: MII transceiver has status %4.4x.\n",

Any chance you could re-diff this to apply on top of the patch posted
earlier today by Neil Horman?

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
