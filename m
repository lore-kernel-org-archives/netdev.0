From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCH 2/4] net: dsa: add new DSA switch driver for the SMSC-LAN9303
Date: Thu, 6 Apr 2017 15:42:28 +0200
Message-ID: <201704061542.29859.jbe@pengutronix.de>
References: <20170405092024.16048-1-jbe@pengutronix.de> <201704061218.57438.jbe@pengutronix.de> <20170406115900.GA13219@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: kernel@pengutronix.de, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33293 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753213AbdDFNnI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 09:43:08 -0400
In-Reply-To: <20170406115900.GA13219@lunn.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Thursday 06 April 2017 13:59:00 Andrew Lunn wrote:
> [...]
> > > Does the MDIO bus go to the outside world? Could there be external
> > > PHYs?
> >
> > ???? This device includes two phys (at port 1 and 2) and these
> > functions are called to detect their state.
>
> Some switches have the MDIO bus available on pins. It is then possible
> to connect additional PHYs on the MDIO bus. If their is an external
> MDIO bus, you should remove the test for phy > phy_base + 2, and allow
> the full range of 32.

Hmm, not sure. You can run this device without a master port and use an 
additional external PHY instead. In this case there is an external MDIO 
available to this external PHY. But I don't know if I can reach this MDIO 
in the same way like the internal MDIO to the built-in PHYs.

> [...]
> > > > +		rc = lan9303_phy_reg_write(chip, chip->phy_addr_sel_strap + 1,
> > > > +					   0, BIT(14) | BIT(11));
> > > > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_RX_CFG_1,
> > > > +					       0x02);
> > > > +		rc += lan9303_write_switch_reg(chip, LAN9303_MAC_TX_CFG_1,
> > > > +					       0x56);
> > >
> > > It seems odd that port_enable does not touch the PHY, but
> > > port_disable does. What is this doing?
> >
> > My experience is, the framework powers up the phys by its own in
> > conjunction with calling lan9303_port_enable(), but do not power down
> > them in conjunction with calling lan9303_port_disable(). In v2 I do not
> > touch the phy anymore.
>
> So this is touching the BMCR_PDOWN bit? Using the #define would of
> helped explain this.

Okay.

Juergen

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
