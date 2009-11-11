From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2] au1000-eth: convert to platform_driver model
Date: Wed, 11 Nov 2009 12:54:15 +0100
Message-ID: <200911111254.16500.florian@openwrt.org>
References: <200911100113.38685.florian@openwrt.org> <f861ec6f0911100120j12d86b0cs3ef9c2816019eaf9@mail.gmail.com>
Reply-To: Florian Fainelli <florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Ralf Baechle <ralf@linux-mips.org>,
	"linux-mips" <linux-mips@linux-mips.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Manuel Lauss <manuel.lauss@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:3161 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036AbZKKLyQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 06:54:16 -0500
Received: by fg-out-1718.google.com with SMTP id d23so1508319fga.1
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 03:54:21 -0800 (PST)
In-Reply-To: <f861ec6f0911100120j12d86b0cs3ef9c2816019eaf9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Manuel,

On Tuesday 10 November 2009 10:20:25 Manuel Lauss wrote:
> Hi Florian,
> 
> On Tue, Nov 10, 2009 at 1:13 AM, Florian Fainelli <florian@openwrt.org> 
wrote:
> > This patch converts the au1000-eth driver to become a full
> > platform-driver as it ought to be. We now pass PHY-speficic
> > configurations through platform_data but for compatibility
> > the driver still assumes the default settings (search for PHY1 on
> > MAC0) when no platform_data is passed. Tested on my MTX-1 board.
[snip]
> >
> > -                       phydev = tmp_phydev;
> > -                       break; /* found it */
> > +               if (aup->phy1_search_mac0) {
> > +                       /* try harder to find a PHY */
> > +                       if (!phydev && (aup->mac_id == 1)) {
> > +                               /* no PHY found, maybe we have a dual
> > PHY? */ +                               printk (KERN_INFO DRV_NAME ": no
> > PHY found on MAC1, " +                                       "let's see
> > if it's attached to MAC0...\n"); +
> > +                               /* find the first (lowest address)
> > non-attached PHY on +                                * the MAC0 MII bus
> > */
> > +                               for (phy_addr = 0; phy_addr <
> > PHY_MAX_ADDR; phy_addr++) { +                                       if
> > (aup->mac_id == 1)
> > +                                               break;
> 
> aup->mac_id needs to be 1 for this loop to be executed in the first
> place, and here
> you immediately bail out if it is.

>From the reading of the comment, it seems to me like we should not do anything 
in this for loop if we were using MAC1, but I may have misunderstood that, as 
such I have added this break to "comply" with the comment.

> Also, how do you access the phy map of the other controller without use of
>  the au_macs[] structure? (which is unused after this patch and could be
>  removed, along
> with the NUM_ETH_INTERFACES constant)

We access the phy map of the other controller by using the correct mii bus 
identifier, since we have registered a per-interface mdio bus or have I 
overlooked something ?

> 
> > +                                       struct phy_device *const
> > tmp_phydev = +                                                      
> > aup->mii_bus->phy_map[phy_addr];
> 
> My compiler complains about mixed code/declarations.

That declaration was already there and as this patch has no intent to clean 
anything right now, I have left it as-is.
--
Florian
