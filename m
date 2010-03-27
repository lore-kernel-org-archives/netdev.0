From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH] netdev/fec.c: add phylib supporting to enable carrier
	detection
Date: Sat, 27 Mar 2010 13:57:03 +0100
Message-ID: <20100327125703.GB5880@pengutronix.de>
References: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4SFOXa2GPu3tIq4H"
Cc: s.hauer@pengutronix.de, gerg@uclinux.org,
	amit.kucheria@canonical.com, netdev@vger.kernel.org,
	kernel-team@lists.ubuntu.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Bryan Wu <bryan.wu@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59539 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001Ab0C0M5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 08:57:05 -0400
Content-Disposition: inline
In-Reply-To: <1269597052-10104-1-git-send-email-bryan.wu@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--4SFOXa2GPu3tIq4H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 26, 2010 at 05:50:52PM +0800, Bryan Wu wrote:
> BugLink: http://bugs.launchpad.net/bugs/457878
>=20
>  - removed old MII phy control code
>  - add phylib supporting
>  - add ethtool interface to make user space NetworkManager works
>=20
> Tested on Freescale i.MX51 Babbage board.

Sadly, I have problems here booting a custom board:

=2E..
FEC Ethernet Driver
fec_enet_mii_bus: probed
eth0: Freescale FEC PHY driver [SMSC LAN8700] (mii_bus:phy_addr=3D0:1f, irq=
=3D-1)

=2E.. (That's fine, so far)

PHY: 0:1f - Link is Up - 100/Full

=2E.. (also nice)

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x2c0/0x2e0()
NETDEV WATCHDOG: eth0 (fec): transmit queue 0 timed out
Modules linked in:
[<c001f8d4>] (unwind_backtrace+0x0/0xe4) from [<c002d1d0>] (warn_slowpath_c=
ommon+0x4c/0x80)
[<c002d1d0>] (warn_slowpath_common+0x4c/0x80) from [<c002d240>] (warn_slowp=
ath_fmt+0x28/0x38)
[<c002d240>] (warn_slowpath_fmt+0x28/0x38) from [<c01be32c>] (dev_watchdog+=
0x2c0/0x2e0)
[<c01be32c>] (dev_watchdog+0x2c0/0x2e0) from [<c0038740>] (run_timer_softir=
q+0x1c0/0x274)
[<c0038740>] (run_timer_softirq+0x1c0/0x274) from [<c0032f98>] (__do_softir=
q+0x8c/0x120)
[<c0032f98>] (__do_softirq+0x8c/0x120) from [<c00330b0>] (irq_exit+0x84/0xa=
0)
[<c00330b0>] (irq_exit+0x84/0xa0) from [<c001a040>] (asm_do_IRQ+0x40/0x8c)
[<c001a040>] (asm_do_IRQ+0x40/0x8c) from [<c001ab8c>] (__irq_svc+0x4c/0x8c)
Exception stack(0xc02c3f78 to 0xc02c3fc0)
3f60:                                                       00000000 000531=
7f
3f80: 0005217f 60000013 c02c2000 c02db7ec c02c59c4 c02c59b8 a0018270 410692=
64
3fa0: a001823c 00000000 600000d3 c02c3fc0 c001ba8c c001ba98 60000013 ffffff=
ff
[<c001ab8c>] (__irq_svc+0x4c/0x8c) from [<c001ba98>] (default_idle+0x2c/0x3=
4)
[<c001ba98>] (default_idle+0x2c/0x34) from [<c001bfac>] (cpu_idle+0x90/0xc8)
[<c001bfac>] (cpu_idle+0x90/0xc8) from [<c000898c>] (start_kernel+0x234/0x2=
c0)
[<c000898c>] (start_kernel+0x234/0x2c0) from [<a0008034>] (0xa0008034)
---[ end trace ce1c823381bff119 ]---
eth0: tx queue full!.
eth0: tx queue full!.
eth0: tx queue full!.
eth0: tx queue full!.
eth0: tx queue full!.
eth0: tx queue full!.
=2E..

I just threw the patch on top of 2.6.33.1, after picking
633e7533cec78b99d806248e832fc83e689d2453 (fec: fix uninitialized rx buffer
usage), too. Just needed to adapt the Kconfig entry, the patch for fec.c we=
nt
smooth. So, I doubt the slightly older kernel is the problem (but will check
net-next somewhen later)? Using the "old" method for the LAN8700, I get a
working eth0, so the hardware should work in general. I will have a closer =
look
on Monday, this was just a quick try. If you happen to have pointers where =
to
start, this is appreciated.

Kind regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--4SFOXa2GPu3tIq4H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkuuAJ8ACgkQD27XaX1/VRt+IQCeLvv9qEbIfGAwCvohLZr475Xq
Ot4An0Jub9VsNMVYDnl90gZtfRHJR2j1
=yqcP
-----END PGP SIGNATURE-----

--4SFOXa2GPu3tIq4H--
