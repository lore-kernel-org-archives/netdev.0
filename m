From: Martin Hicks <mort@bork.org>
Subject: r8169 cardbus device naming weirdness
Date: Tue, 23 May 2006 13:44:02 -0400
Message-ID: <20060523174402.GG29687@bork.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="lIrNkN/7tmsD/ALM"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from galileo.bork.org ([134.117.69.57]:8107 "EHLO galileo.bork.org")
	by vger.kernel.org with ESMTP id S932107AbWEWRoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:44:03 -0400
To: romieu@fr.zoreil.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--lIrNkN/7tmsD/ALM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,

I've got a D-Link DGE-660TD that the driver claims to register as eth1,
but it actually ends up being eth2.  (eth0 is the on-board NIC).

mort@socrates:~$ dmesg

[...]

r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
ACPI: PCI Interrupt 0000:07:00.0[A] -> Link [LNKB] -> GSI 5 (level, low) ->=
 IRQ 5
eth1: Identified chip type is 'RTL8169s/8110s'.
eth1: RTL8169 at 0xe8a36000, 00:13:46:29:65:62, IRQ 5
mort@socrates:~$ sudo /sbin/ifconfig eth1 192.168.1.102 netmask 255.255.255=
=2E0
SIOCSIFADDR: No such device
eth1: ERROR while getting interface flags: No such device
SIOCSIFNETMASK: No such device
mort@socrates:~$ sudo /sbin/ifconfig eth2 192.168.1.102 netmask 255.255.255=
=2E0
mort@socrates:~$ sudo /usr/sbin/ethtool -i eth2
driver: r8169
version: 2.2LK-NAPI
firmware-version:=20
bus-info: 0000:07:00.0
mort@socrates:~$ sudo /usr/sbin/ethtool -i eth1=20
Cannot get driver information: No such device
mort@socrates:~$=20


On a IBM T23 laptop running 2.6.16.14.

--=20
Martin Hicks || mort@bork.org || PGP/GnuPG: 0x4C7F2BEE

--lIrNkN/7tmsD/ALM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFEc0ni0ZUZrUx/K+4RAq77AJ9x6js3h66oNQsBL3wR86/5/etcqgCfWVkn
NMXYuBFUsFLAXtzRFFMd8EA=
=qQbp
-----END PGP SIGNATURE-----

--lIrNkN/7tmsD/ALM--
