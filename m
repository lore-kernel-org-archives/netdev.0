From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/6] phylib: add the ICPlus IP175C PHY driver
Date: Wed, 09 May 2007 19:35:35 -0400
Message-ID: <46425AC7.5070808@garzik.org>
References: <20070508175010.4c024666.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50159 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755579AbXEIXfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 19:35:38 -0400
In-Reply-To: <20070508175010.4c024666.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> +		/* master reset */
> +		err = phydev->bus->write(phydev->bus, 30, 0, 0x175c);
> +		if (err < 0)
> +			return err;
> +
> +		/* data sheet specifies reset period is 2 msec */
> +		udelay(3000);
> +
> +		/* enable IP175C mode */
> +		err = phydev->bus->write(phydev->bus, 29, 31, 0x175c);
> +		if (err < 0)
> +			return err;

1) use mdelay()

2) write-followed-by-delay does not guarantee the delay, because you 
have not factored in PCI posting (or other bus delays)


> +		/* Set MII0 speed and duplex (in PHY mode) */
> +		err = phydev->bus->write(phydev->bus, 29, 22, 0x420);
> +		if (err < 0)
> +			return err;
> +
> +		for (i=0; i<5; i++) {
> +			err = phydev->bus->write(phydev->bus, i, MII_BMCR, BMCR_RESET);
> +		}
> +		udelay(3000);

ditto


> +		full_reset_performed = 1;
> +	}
> +
> +	if (phydev->addr != 4) {
> +		phydev->state = PHY_RUNNING;
> +		phydev->speed = SPEED_100;
> +		phydev->duplex = DUPLEX_FULL;
> +		phydev->link = 1;
> +		netif_carrier_on(phydev->attached_dev);
> +	}
> +
> +	return 0;
> +}
> +
> +static int ip175c_read_status(struct phy_device *phydev)
> +{
> +	if (phydev->addr == 4) { /* if WAN port */
> +		genphy_read_status(phydev);
> +	} else {
> +		/* Don't need to read status for switch ports */
> +		phydev->irq = PHY_IGNORE_INTERRUPT;
> +	}
> +
> +	return 0;
> +}
> +
> +
> +static int ip175c_config_aneg(struct phy_device *phydev)
> +{
> +	if (phydev->addr == 4) { /* if WAN port */
> +		genphy_config_aneg(phydev);
> +	}

codingstyle: remove braces around single C statements

