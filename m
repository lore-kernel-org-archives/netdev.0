From: David Miller <davem@davemloft.net>
Subject: Re: randconfig build error with next-20141210, in
 drivers/net/ethernet/broadcom/genet
Date: Fri, 12 Dec 2014 11:02:23 -0500 (EST)
Message-ID: <20141212.110223.1096319955510441330.davem@davemloft.net>
References: <CA+r1ZhjxtK8BtF16Mr9jXjqvFVV7KAAFjWqfVFUibNreZwZxTw@mail.gmail.com>
	<20141211.142220.610076934853342634.davem@davemloft.net>
	<548A786D.2060201@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jim.epost@gmail.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030544AbaLLQCZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:02:25 -0500
In-Reply-To: <548A786D.2060201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 11 Dec 2014 21:09:01 -0800

> Le 11/12/2014 11:22, David Miller a =E9crit :
>> From: Jim Davis <jim.epost@gmail.com> Date: Wed, 10 Dec 2014
>> 09:10:45 -0700
>>=20
>>> Building with the attached random configuration file,
>>>=20
>>> ERROR: "fixed_phy_register"=20
>>> [drivers/net/ethernet/broadcom/genet/genet.ko] undefined!
>>=20
>> Florian, I don't understand why FIXED_PHY is only selected in
>> Kconfig if the driver is statically built into the kernel.
>>=20
>> That makes no sense at all, you should need that module regardless
>> of how the driver itself is enabled.
>=20
> AFAIR this was introduced to silence a warning you reported:
>=20
> "I think you need to work on the Kconfig dependencies a little bit mo=
re.
> I have BCMGENET specified as modular, which absolutely should work.  =
Yet
> Kconfig complains.
>=20
> warning: (BCMGENET) selects FIXED_PHY which has unmet direct
> dependencies (NETDEVICES && PHYLIB=3Dy)"
>=20
> but I agree, this makes no sense, we should select FIXED_PHY
> unconditionnally, will send you patches tomorrow to fix that.

What's really perplexing is that FIXED_PHY is only enable'able
when PHYLIB=3Dy.  I think that's the core of the problems here.

All of these drivers shouldn't lose fixed phy support simply
because they, or PHYLIB itself, is built modular.
