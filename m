From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: still having r8169 woes with XID 18000000
Date: Fri, 04 Jun 2010 16:02:11 +0300
Message-ID: <4C08F953.1050800@iki.fi>
References: <4C08ED47.1030800@iki.fi> <20100604123641.ED8154CD45@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?ZnJhbsOnb2lzIHJvbWlldQ==?= <romieu@fr.zoreil.com>
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:53215 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab0FDNCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 09:02:13 -0400
Received: by ey-out-2122.google.com with SMTP id 25so100768eya.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 06:02:10 -0700 (PDT)
In-Reply-To: <20100604123641.ED8154CD45@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2010 03:36 PM, Phil Sutter wrote:
> On Fri, Jun 04, 2010 at 03:10:47PM +0300, Timo Ter=C3=A4s wrote:
>> After fixing the MAC issues earlier, I'm still seeing some weird tro=
uble
>> with my RTL8169sc/8110sc / XID 18000000 boards.
>>
>> The box(es) were originally running 2.6.30.x kernel and everything
>> worked without major problems. But after upgrading to 2.6.32.x (and =
even
>> with most of the newer fixes included too), it seems that the someti=
mes
>> (not too often) some of the interfaces just won't work after reboot
>> (cold or hard). It's a 3-in-1 board, and usually when this happens o=
ne
>> of the interfaces won't work but the other two do work.
>>
>> Whenever an interface is "broken", the following conditions are true=
:
>>  - forcing it to 10mbit/s and disabling autoneg will make it work
>>  - when it's not working ethtool -S reports rx_errors and align_erro=
rs
>> increasing
>>  - when autoneg is on, ethtool says that "Link Detected: no"
>=20
> This (your last point) is about what we were experiencing at work usi=
ng
> PCI-based Gigabit Realtek NICs. Our solution to the problem was to
> switch to a different NIC (Intel e1000), which obviously solves any
> problems. ;)
>=20
> But I've done some tests before, mainly being inspired by these mails=
:
> http://permalink.gmane.org/gmane.linux.network/160136
> http://permalink.gmane.org/gmane.linux.network/160280
> and after some feedback from the mainboard manufacturer I've tested t=
he
> out-of-tree driver Realtek provides (version 6.013.00), which seems t=
o
> not have this issue. Very interesting results show up when comparing
> 6.013 with 6.012 (citing myself):
>=20
> Comparing r8169-6.013 with it's predecessor 6.012, you'll find a newl=
y
> enabled function rtl8169_phy_power_up() as well as some more invocati=
ons
> of rtl8169_phy_power_down().
>=20
> This is probably the solution to these (at least in our case) very
> sporadic, but highly annoying, problems. In fact, when our NIC didn't
> detect any link, it needed a full power-cycle (no success with
> reset-button), so almost not workaroundable.

Sounds very similar to the problem I have. Thanks for the pointers!

It looks like the r8169 driver does have phy power up code in it, but
it's only executed for specific versions of the chip. Realtek driver
seems to do it unconditionally.

The check seems to be:
                if ((tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11) ||
                    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_12) ||
                    (tp->mac_version >=3D RTL_GIGA_MAC_VER_17)) {

I wonder if I should just add my mac version there (_VER_05) and test i=
f
it'll make it better.

- Timo
