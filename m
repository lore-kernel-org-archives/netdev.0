From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] PowerPC: Add BCM5248 and Marvell 88E1111 PHY support to
 NEW EMAC.
Date: Tue, 23 Oct 2007 10:20:35 -0500
Message-ID: <20071023102035.6d35d3fe@weaponx.rchland.ibm.com>
References: <20071015175717.GA4602@ru.mvista.com>
	<4713B10B.5000607@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valentine Barshak <vbarshak@ru.mvista.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:33387 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbXJWPU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 11:20:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9NFKqgH001129
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 11:20:52 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9NFKcQJ060168
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 09:20:38 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9NFKbbx008107
	for <netdev@vger.kernel.org>; Tue, 23 Oct 2007 09:20:38 -0600
In-Reply-To: <4713B10B.5000607@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Oct 2007 14:27:23 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Valentine Barshak wrote:
> > This patch adds BCM5248 and Marvell 88E1111 PHY support to NEW EMAC driver.
> > These PHY chips are used on PowerPC 440EPx boards.
> > The PHY code is based on the previous work by Stefan Roese <sr@denx.de>
> > 
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
> > ---
> >  drivers/net/ibm_newemac/phy.c |   39 +++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 39 insertions(+)
> > 
> > --- linux.orig/drivers/net/ibm_newemac/phy.c	2007-06-15 21:45:18.000000000 +0400
> > +++ linux/drivers/net/ibm_newemac/phy.c	2007-06-15 20:45:15.000000000 +0400
> > @@ -306,8 +306,47 @@
> >  	.ops		= &cis8201_phy_ops
> >  };
> >  
> > +static struct mii_phy_def bcm5248_phy_def = {
> > +
> > +	.phy_id		= 0x0143bc00,
> > +	.phy_id_mask	= 0x0ffffff0,
> > +	.name		= "BCM5248 10/100 SMII Ethernet",
> > +	.ops		= &generic_phy_ops
> > +};
> > +
> > +static int m88e1111_init(struct mii_phy *phy)
> > +{
> > +	printk("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
> > +	phy_write(phy, 0x14, 0x0ce3);
> > +	phy_write(phy, 0x18, 0x4101);
> > +	phy_write(phy, 0x09, 0x0e00);
> > +	phy_write(phy, 0x04, 0x01e1);
> > +	phy_write(phy, 0x00, 0x9140);
> > +	phy_write(phy, 0x00, 0x1140);
> > +
> > +	return  0;
> > +}
> > +
> > +static struct mii_phy_ops m88e1111_phy_ops = {
> > +	.init		= m88e1111_init,
> > +	.setup_aneg	= genmii_setup_aneg,
> > +	.setup_forced	= genmii_setup_forced,
> > +	.poll_link	= genmii_poll_link,
> > +	.read_link	= genmii_read_link
> > +};
> > +
> > +static struct mii_phy_def m88e1111_phy_def = {
> > +
> > +	.phy_id		= 0x01410CC0,
> > +	.phy_id_mask	= 0x0ffffff0,
> > +	.name		= "Marvell 88E1111 Ethernet",
> > +	.ops		= &m88e1111_phy_ops,
> > +};
> > +
> >  static struct mii_phy_def *mii_phy_table[] = {
> >  	&cis8201_phy_def,
> > +	&bcm5248_phy_def,
> > +	&m88e1111_phy_def,
> >  	&genmii_phy_def,
> 
> Seems sane to me -- ACK -- but we have multiple people sending me 
> patches for a single driver.  That's normal for janitorial cleanups 
> across the whole tree, but discouraged when multiple people are actively 
> working on the same driver.
> 
> Please coordinate, and have ONE person send me patches...

Jeff, could you please pull in this patch for 2.6.24?  We'll get the
coordination down for any further patches.

thx,
josh
> 
