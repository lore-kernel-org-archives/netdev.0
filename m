From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phylib: Don't allow core of phylib to build as a module
Date: Mon, 2 Jun 2008 14:44:42 -0500
Message-ID: <83820D83-487C-4586-9867-F4226A87A276@freescale.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:57319 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755094AbYFBTpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 15:45:09 -0400
In-Reply-To: <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 2, 2008, at 14:30, Kumar Gala wrote:

>
> On Jun 2, 2008, at 11:39 AM, Jeff Garzik wrote:
>
> If you really think the core of the phylib should be able to be  
> built as a module than we could possibly add function pointers to  
> phy_dev to do the real phy_read()/phy_write() and change phy_read/ 
> _write to look like:
>
> int phy_read(struct phy_device *phydev, u16 regnum) {
> 	return phydev->read(phydev, regnum);
> }

That would be a bit silly, since this is the definition of phy_read():

int phy_read(struct phy_device *phydev, u16 regnum)
{
         int retval;
         struct mii_bus *bus = phydev->bus;

         BUG_ON(in_interrupt());

         mutex_lock(&bus->mdio_lock);
         retval = bus->read(bus, phydev->addr, regnum);
         mutex_unlock(&bus->mdio_lock);

         return retval;
}


We could, of course, move phy_read *out* of the phylib module.  And  
also phy_register_fixup and any other functions needed by board code.

I'm partial to the select-it-if-you-need-it paradigm.

Andy
