From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv2 net] phy: micrel: Fix finding PHY properties in MAC node.
Date: Wed, 09 Dec 2015 13:40:25 -0800
Message-ID: <E3964CA5-5DD3-4479-B6B9-27982D1A0908@gmail.com>
References: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, dinguyen@opensource.altera.com,
	david.daney@cavium.com
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36639 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbbLIVkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:40:33 -0500
Received: by oiww189 with SMTP id w189so34312223oiw.3
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 13:40:32 -0800 (PST)
In-Reply-To: <1449687391-15331-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On December 9, 2015 10:56:31 AM PST, Andrew Lunn <andrew@lunn.ch> wrote=
:
>commit 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus,
>not the bus' parent.")  changed the parenting of PHY devices, making
>them a child of the MDIO bus, instead of the MAC device. This broken
>the Micrel PHY driver which has a deprecated feature of allowing PHY
>properties to be placed into the MAC node.
>
>In order to find the MAC node, we need to walk up the tree of devices
>until we find one with an OF node attached.
>
>Reported-by: Dinh Nguyen <dinguyen@opensource.altera.com>
>Suggested-by: David Daney <david.daney@cavium.com>
>Acked-by: David Daney <david.daney@cavium.com>
>Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, no=
t
>the bus' parent.")
>Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>---

>-	if (!of_node && dev->parent->of_node)
>-		of_node =3D dev->parent->of_node;
>+	/* The Micrel driver has a deprecated option to place phy OF
>+	 * properties in the MAC node. Walk up the tree of devices to
>+	 * find a device with an OF node.
>+	 */
>+	dev_walker =3D &phydev->dev;
>+	do {
>+		of_node =3D dev_walker->of_node;
>+		dev_walker =3D dev_walker->parent;
>+
>+	} while (!of_node && dev_walker);

Looks good to me, can we also issuing =C3=A0 warning so people get a ch=
ance to update their Device Tree?

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
>=20
> 	if (of_node) {
> 		ksz9021_load_values_from_of(phydev, of_node,

--=20
=46lorian
