From: Florian Lohoff <flo@rfc822.org>
Subject: acenic swallowing 802.1q tag when kernel compiled with VLAN support
Date: Fri, 16 Feb 2007 12:30:53 +0100
Message-ID: <20070216113053.GA15661@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.gt.owl.de ([195.71.99.218]:54209 "EHLO hydra.gt.owl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbXBPMBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 07:01:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi,
i discovered that once the kernel is compiled 802.1Q VLAN Support the aceni=
c driver
swallows the 802.1q header in promiscous mode. I am tracing an gigabit ethe=
rnet
with 802.1q in 802.1q so i would usually see 2 802.1q VLAN header. When com=
piling
with VLAN aka 802.1q support the first or outer vlan header disappears from=
 the traces
even though the vlan support kernel module is not loaded nor vlans activate=
d on the link.

Card i am using:

	0000:06:02.0 Ethernet controller: 3Com Corporation 3c985 1000BaseSX (SX/TX=
) (rev 01)
		Subsystem: Unknown device 9850:0001
		Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepp=
ing- SERR+ FastB2B-
		Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TAbor=
t- <MAbort- >SERR- <PERR-
		Latency: 64 (16000ns min), Cache Line Size: 0x10 (64 bytes)
		Interrupt: pin A routed to IRQ 225
		Region 0: Memory at fdff0000 (32-bit, non-prefetchable) [size=3D16K]

dmesg output:

	acenic.c: v0.92 08/05/2002  Jes Sorensen, linux-acenic@SunSITE.dk
				    http://home.cern.ch/~jes/gige/acenic.html
	ACPI: PCI Interrupt 0000:06:02.0[A] -> GSI 78 (level, low) -> IRQ 225
	0000:06:02.0: 3Com 3C985 Gigabit Ethernet at 0xfdff0000, irq 225
	  Tigon II (Rev. 6), Firmware: 12.4.11, MAC: 00:60:08:f6:f5:4e
	  PCI cache line size set incorrectly (64 bytes) by BIOS/FW, expecting 32
	  PCI bus width: 64 bits, speed: 66MHz, latency: 64 clks
	  Disabling PCI memory write and invalidate
	0000:06:02.0: Firmware up and running

Kernel:
	lnxp-1115:~# uname -a
	Linux lnxp-1115 2.6.18-3-686 #1 SMP Mon Dec 4 16:41:14 UTC 2006 i686 GNU/L=
inux

	lnxp-1115:~# egrep "CONFIG_ACENIC|CONFIG_VLAN" /boot/config-2.6.18-3-686
	CONFIG_VLAN_8021Q=3Dm
	CONFIG_ACENIC=3Dm
	# CONFIG_ACENIC_OMIT_TIGON_I is not set

Thats the default Debian Etch kernel. I have seen this behaviour in a coupl=
e kernel
releases since i started tracing stuff so its not a new bug.

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFF1ZXtUaz2rXW+gJcRAlyPAKCxqO88n0P2H5kMeKOMBSMHn3U5VgCg4nwg
RJKRJZHuLgO7CALH8pHlZ1c=
=44MA
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
