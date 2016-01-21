From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 08/28] net: dsa: Keep the mii bus and address in the
 private structure
Date: Thu, 21 Jan 2016 21:50:53 +0100
Message-ID: <20160121205053.GJ9991@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <1450875402-20740-9-git-send-email-andrew@lunn.ch>
 <874me64qdo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	netdev <netdev@vger.kernel.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40538 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbcAUUuz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 15:50:55 -0500
Content-Disposition: inline
In-Reply-To: <874me64qdo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > @@ -176,6 +170,15 @@ static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
> >  {
> >  	int i;
> >  	int ret;
> > +	struct mv88e6060_priv *priv;
> > +
> > +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> > +	if (!priv)
> > +		return -ENOMEM;
> > +
> > +	ds->priv = priv;
> > +	priv->bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> 
> This patch drops the checks for !bus, and thus mdiobus_write_nested can
> segfault later. Maybe restore the check here?

Agreed. I will post a refresh of these patches in a few days. I made a
few changes to integrate with the mdio device patchset which has
recently been merged.

	 Andrew
