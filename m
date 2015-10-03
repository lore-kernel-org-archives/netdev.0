From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: dsa: better error reporting
Date: Sat, 3 Oct 2015 13:16:11 -0700
Message-ID: <5610378B.4020009@gmail.com>
References: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, Guenter Roeck <linux@roeck-us.net>
To: Russell King <rmk+kernel@arm.linux.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:36608 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbbJCUQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 16:16:13 -0400
Received: by obcgx8 with SMTP id gx8so104242109obc.3
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 13:16:13 -0700 (PDT)
In-Reply-To: <E1ZiQJ1-0003q8-78@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/10/2015 10:09, Russell King a =C3=A9crit :
> Add additional error reporting to the generic DSA code, so it's easie=
r
> to debug when things go wrong.  This was useful when initially bringi=
ng
> up 88e6176 on a new board.
>=20
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---

[snip]

>  	} else {
>  		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
>  			    p->phy->addr, p->phy->drv->name);
> @@ -1195,6 +1202,7 @@ int dsa_slave_create(struct dsa_switch *ds, str=
uct device *parent,
> =20
>  	ret =3D dsa_slave_phy_setup(p, slave_dev);
>  	if (ret) {
> +		netdev_err(master, "error %d setting up slave phy\n", ret);
>  		free_netdev(slave_dev);
>  		return ret;

All of these debug messages are going to happen prior to the slave
network device being registered, so you would get these error messages
to be printed with an extraneous " (unregistered)" which is fine, just =
a
tad annoying sometimes.

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--=20
=46lorian
