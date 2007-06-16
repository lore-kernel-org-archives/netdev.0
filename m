From: Maximilian Engelhardt <maxi@daemonizer.de>
Subject: b44: high ping times with wireless-dev
Date: Sat, 16 Jun 2007 23:27:43 +0200
Message-ID: <200706162327.47413.maxi@daemonizer.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9854408.IIlnzTzavd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-wireless" <linux-wireless@vger.kernel.org>,
	Michael Buesch <mb@bu3sch.de>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from daemonizer.de ([87.230.16.230]:55386 "EHLO daemonizer.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664AbXFPV2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2007 17:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart9854408.IIlnzTzavd
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

I recently did some test and found out something interesting about the b44=
=20
problem I wrote earlier.=20

The problem is the following:
When I use my BCM4401 with the b44 driver in wireless-dev I get very high p=
ing=20
times looking like this:

64 bytes from 172.30.10.1: icmp_seq=3D1 ttl=3D64 time=3D1863 ms
64 bytes from 172.30.10.1: icmp_seq=3D2 ttl=3D64 time=3D855 ms
64 bytes from 172.30.10.1: icmp_seq=3D3 ttl=3D64 time=3D1855 ms
64 bytes from 172.30.10.1: icmp_seq=3D4 ttl=3D64 time=3D855 ms
64 bytes from 172.30.10.1: icmp_seq=3D5 ttl=3D64 time=3D1854 ms
64 bytes from 172.30.10.1: icmp_seq=3D6 ttl=3D64 time=3D854 ms
64 bytes from 172.30.10.1: icmp_seq=3D7 ttl=3D64 time=3D1851 ms
64 bytes from 172.30.10.1: icmp_seq=3D8 ttl=3D64 time=3D851 ms
64 bytes from 172.30.10.1: icmp_seq=3D9 ttl=3D64 time=3D1851 ms
64 bytes from 172.30.10.1: icmp_seq=3D10 ttl=3D64 time=3D851 ms

I also found out that shortly after I boot my laptop and log into kde ping=
=20
times are not that high but start to increase very quickly:

64 bytes from 172.30.10.1: icmp_seq=3D53 ttl=3D64 time=3D2.19 ms
64 bytes from 172.30.10.1: icmp_seq=3D54 ttl=3D64 time=3D2.22 ms
64 bytes from 172.30.10.1: icmp_seq=3D55 ttl=3D64 time=3D2.20 ms
64 bytes from 172.30.10.1: icmp_seq=3D56 ttl=3D64 time=3D2.20 ms
64 bytes from 172.30.10.1: icmp_seq=3D57 ttl=3D64 time=3D18.6 ms
64 bytes from 172.30.10.1: icmp_seq=3D58 ttl=3D64 time=3D1268 ms
64 bytes from 172.30.10.1: icmp_seq=3D59 ttl=3D64 time=3D268 ms
64 bytes from 172.30.10.1: icmp_seq=3D60 ttl=3D64 time=3D1268 ms
64 bytes from 172.30.10.1: icmp_seq=3D61 ttl=3D64 time=3D268 ms
64 bytes from 172.30.10.1: icmp_seq=3D62 ttl=3D64 time=3D6.08 ms
64 bytes from 172.30.10.1: icmp_seq=3D63 ttl=3D64 time=3D268 ms
64 bytes from 172.30.10.1: icmp_seq=3D64 ttl=3D64 time=3D1264 ms
64 bytes from 172.30.10.1: icmp_seq=3D65 ttl=3D64 time=3D264 ms

After some time digging around I found out something really interesting. Wh=
en=20
I play some music ping times are immediately lower. If I stop playing music=
=20
they are back to the same times as they were before.

I guess that there is a problem with interrupts so I post some information =
of=20
my system in hope it will be usefull.

maxi@koala:~$ cat /proc/interrupts
          CPU0      =20
 0:     126317    XT-PIC-XT        timer
 1:       3600    XT-PIC-XT        i8042
 2:          0    XT-PIC-XT        cascade
 7:          1    XT-PIC-XT        parport0
 8:          1    XT-PIC-XT        rtc
 9:      17371    XT-PIC-XT        acpi
10:      13237    XT-PIC-XT        firewire_ohci, yenta, yenta, ehci_hcd:us=
b1,=20
uhci_hcd:usb3, uhci_hcd:usb4, Intel 82801DB-ICH4, Intel 82801DB-ICH4 Modem,=
=20
eth0
11:      89059    XT-PIC-XT        uhci_hcd:usb2, i915@pci:0000:00:02.0
12:        632    XT-PIC-XT        i8042
14:      10354    XT-PIC-XT        libata
15:       7408    XT-PIC-XT        libata
NMI:          0=20
ERR:          0


[...]
ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 10
ACPI: PCI Interrupt 0000:02:02.0[A] -> Link [LNKD] -> GSI 10 (level, low) -=
>=20
IRQ 10
ssb: Sonics Silicon Backplane found on PCI device 0000:02:02.0
b44.c:v2.0
eth0: Broadcom 44xx/47xx 10/100BaseT Ethernet 00:c0:9f:29:99:a7
[...]

This problem did only happen with wireless-dev (checkout this evening) and=
=20
with -mm kernels I used some time ago for testing. Currently I'm running=20
2.6.22-rc4 that works perfectly fine and doesn't show that problem.

Maxi

--nextPart9854408.IIlnzTzavd
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGdFXTOimwv528XGERAlEVAKDBDmhNPMN8i4bJKsuisJgvHqgGswCg5Pgh
9wUy0qGH9zi/fBpQMCYxG1I=
=HxBs
-----END PGP SIGNATURE-----

--nextPart9854408.IIlnzTzavd--
