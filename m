From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: randconfig build error with next-20141210, in drivers/net/ethernet/broadcom/genet
Date: Thu, 11 Dec 2014 21:09:01 -0800
Message-ID: <548A786D.2060201@gmail.com>
References: <CA+r1ZhjxtK8BtF16Mr9jXjqvFVV7KAAFjWqfVFUibNreZwZxTw@mail.gmail.com> <20141211.142220.610076934853342634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jim.epost@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141211.142220.610076934853342634.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 11/12/2014 11:22, David Miller a =E9crit :
> From: Jim Davis <jim.epost@gmail.com> Date: Wed, 10 Dec 2014
> 09:10:45 -0700
>=20
>> Building with the attached random configuration file,
>>=20
>> ERROR: "fixed_phy_register"=20
>> [drivers/net/ethernet/broadcom/genet/genet.ko] undefined!
>=20
> Florian, I don't understand why FIXED_PHY is only selected in
> Kconfig if the driver is statically built into the kernel.
>=20
> That makes no sense at all, you should need that module regardless
> of how the driver itself is enabled.

AFAIR this was introduced to silence a warning you reported:

"I think you need to work on the Kconfig dependencies a little bit more=
=2E
I have BCMGENET specified as modular, which absolutely should work.  Ye=
t
Kconfig complains.

warning: (BCMGENET) selects FIXED_PHY which has unmet direct
dependencies (NETDEVICES && PHYLIB=3Dy)"

but I agree, this makes no sense, we should select FIXED_PHY
unconditionnally, will send you patches tomorrow to fix that.

>=20
> Can't we just remove the "XXX=3Dy" in all of those silly:
>=20
> select FIXED_PHY if XXX=3Dy
>=20
> expressions?
>=20
> There are three such cases right now:
>=20
> drivers/net/dsa/Kconfig:	select FIXED_PHY if NET_DSA_BCM_SF2=3Dy=20
> drivers/net/ethernet/broadcom/Kconfig:	select FIXED_PHY if
> BCMGENET=3Dy drivers/net/ethernet/broadcom/Kconfig:	select FIXED_PHY
> if SYSTEMPORT=3Dy
>=20


--=20
=46lorian
