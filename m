From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCHv2 net] phy: micrel: Fix finding PHY properties in MAC
 node.
Date: Wed, 9 Dec 2015 22:57:52 +0100
Message-ID: <20151209215752.GA16723@lunn.ch>
References: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
 <E3964CA5-5DD3-4479-B6B9-27982D1A0908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, dinguyen@opensource.altera.com,
	david.daney@cavium.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34374 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbbLIV54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2015 16:57:56 -0500
Content-Disposition: inline
In-Reply-To: <E3964CA5-5DD3-4479-B6B9-27982D1A0908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >-	if (!of_node && dev->parent->of_node)
> >-		of_node =3D dev->parent->of_node;
> >+	/* The Micrel driver has a deprecated option to place phy OF
> >+	 * properties in the MAC node. Walk up the tree of devices to
> >+	 * find a device with an OF node.
> >+	 */
> >+	dev_walker =3D &phydev->dev;
> >+	do {
> >+		of_node =3D dev_walker->of_node;
> >+		dev_walker =3D dev_walker->parent;
> >+
> >+	} while (!of_node && dev_walker);
>=20
> Looks good to me, can we also issuing =E0 warning so people get a cha=
nce to update their Device Tree?

I did wounder about that.

But i think it might be better to wait until there are updated dts
files. No point telling users they need to update when there are no
updated DT files to use.

If Dinh updates the SoCFPGA .dts files then i think it makes sense to
add the warning.

    Andrew
