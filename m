From: Phil Sutter <phil@nwl.cc>
Subject: Re: still having r8169 woes with XID 18000000
Date: Fri, 4 Jun 2010 14:36:34 +0200
Message-ID: <20100604123641.ED8154CD45@orbit.nwl.cc>
References: <4C08ED47.1030800@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?ZnJhbsOnb2lz?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.169.95]:51227 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637Ab0FDMgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 08:36:43 -0400
Content-Disposition: inline
In-Reply-To: <4C08ED47.1030800@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Jun 04, 2010 at 03:10:47PM +0300, Timo Ter=C3=A4s wrote:
> After fixing the MAC issues earlier, I'm still seeing some weird trou=
ble
> with my RTL8169sc/8110sc / XID 18000000 boards.
>=20
> The box(es) were originally running 2.6.30.x kernel and everything
> worked without major problems. But after upgrading to 2.6.32.x (and e=
ven
> with most of the newer fixes included too), it seems that the sometim=
es
> (not too often) some of the interfaces just won't work after reboot
> (cold or hard). It's a 3-in-1 board, and usually when this happens on=
e
> of the interfaces won't work but the other two do work.
>=20
> Whenever an interface is "broken", the following conditions are true:
>  - forcing it to 10mbit/s and disabling autoneg will make it work
>  - when it's not working ethtool -S reports rx_errors and align_error=
s
> increasing
>  - when autoneg is on, ethtool says that "Link Detected: no"

This (your last point) is about what we were experiencing at work using
PCI-based Gigabit Realtek NICs. Our solution to the problem was to
switch to a different NIC (Intel e1000), which obviously solves any
problems. ;)

But I've done some tests before, mainly being inspired by these mails:
http://permalink.gmane.org/gmane.linux.network/160136
http://permalink.gmane.org/gmane.linux.network/160280
and after some feedback from the mainboard manufacturer I've tested the
out-of-tree driver Realtek provides (version 6.013.00), which seems to
not have this issue. Very interesting results show up when comparing
6.013 with 6.012 (citing myself):

Comparing r8169-6.013 with it's predecessor 6.012, you'll find a newly
enabled function rtl8169_phy_power_up() as well as some more invocation=
s
of rtl8169_phy_power_down().

This is probably the solution to these (at least in our case) very
sporadic, but highly annoying, problems. In fact, when our NIC didn't
detect any link, it needed a full power-cycle (no success with
reset-button), so almost not workaroundable.

HTH, Phil
