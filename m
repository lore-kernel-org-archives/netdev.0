From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Wed, 23 Dec 2015 12:44:59 -0800
Message-ID: <567B07CB.5080308@gmail.com>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35728 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509AbbLWUpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 15:45:01 -0500
Received: by mail-ob0-f178.google.com with SMTP id 18so173533651obc.2
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 12:45:00 -0800 (PST)
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Le 23/12/2015 04:56, Andrew Lunn a =C3=A9crit :
> As noted in Documentation/networking/dsa/dsa.txt, the current DSA
> architecture has a few architecture problems:
>=20
> DSA is implemented as a DSA platform device driver which is convenien=
t because
> it will register the entire DSA switch tree attached to a master netw=
ork device
> in one-shot, facilitating the device creation and simplifying the dev=
ice driver
> model a bit, this comes however with a number of limitations:
>=20
> - building DSA and its switch drivers as modules is currently not wor=
king
> - the device driver parenting does not necessarily reflect the origin=
al
>   bus/device the switch can be created from
> - supporting non-MDIO and non-MMIO (platform) switches is not possibl=
e
>=20
> This RFC patchset attempts to address this. It allows the switch
> device to be true Linux devices, and use of the device component
> framework to bind the switch devices to the DSA framework, similar to
> the way GPU engines are bound to the master GPU driver. The drivers
> are now modules, which can be loaded and unloaded. Reloading however
> currently causes an Opps, hence RFC.
>=20
> The code remains backwards compatible with the old binding, and adds =
a
> new property to facilitate the component framework. Switch drivers ge=
t
> there own binding, allowing them to be probed independent of DSA.

Well, sort of, and that is the part that gives me mixed feelings right
now. Your conversion of the bcm_sf2 driver, although it looks good and
gets us where we should go, still poses a major problem for my platform=
s
where a wrong DTB is frozen (at least for some time).

I would very much like to make it possible for the bcm_sf2 driver to be
a real platform driver, call into dsa_switch_register(), yet remain
compatible with the old binding by using dsa_of_probe(), it could be
based on the compatible string we get probed with, it could be up to th=
e
caller or the callee to attempt both bindings to be parsed etc.

I still think that using a 'dsa' platform device and having to bind
other drivers to it is just an artifact and relic from the original
design that we do not necessarily need anymore but with the components
framework, it seems to get us in a better shape.

That being said, thanks a lot for getting the patches out!
--=20
=46lorian
