From: Albrecht =?iso-8859-1?b?RHJl3w==?= <albrecht.dress@arcor.de>
Subject: Q: disable IGMP_ALL_HOSTS from user-space?
Date: Wed, 08 Apr 2015 21:10:50 +0200
Message-ID: <5AKR4w8ow32d8M4zdUUba2@bZstzQRdmU9aO/MbbcXCI>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
	protocol="application/pgp-signature"; boundary="=-5VN1rrKdQpsHdjeSgi1U"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-02.arcor-online.net ([151.189.21.42]:48511 "EHLO
	mail-in-02.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753290AbbDHTKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 15:10:53 -0400
Received: from mail-in-02-z2.arcor-online.net (mail-in-19-z2.arcor-online.net [151.189.8.36])
	by mx.arcor.de (Postfix) with ESMTP id 3lMZvH41C1z1Sv1
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 21:10:51 +0200 (CEST)
Received: from mail-in-06.arcor-online.net (mail-in-06.arcor-online.net [151.189.21.46])
	by mail-in-02-z2.arcor-online.net (Postfix) with ESMTP id 8655835B9E3
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 21:10:51 +0200 (CEST)
Received: from antares.localdomain (xdsl-89-0-89-91.netcologne.de [89.0.89.91])
	(Authenticated sender: dralbrecht.dress@arcor.de)
	by mail-in-06.arcor-online.net (Postfix) with ESMTPSA id 3lMZvH3Kcdz8FnG
	for <netdev@vger.kernel.org>; Wed,  8 Apr 2015 21:10:51 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-5VN1rrKdQpsHdjeSgi1U
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

a hopefully not too dumb question, and for the right list...

I noticed that Linux always adds IGMP_ALL_HOSTS (224.0.0.1) to the nic's "w=
hitelist", even if multicasting for the interface has been disabled, i.e. s=
tarted via the SIOCSIFFLAGS ioctl /without/ IFF_MULTICAST in ifr_flags.  Is=
 it possible to disable this behaviour via software, so that the system beh=
aves like a device according to RFC 1112 Level 0 or Level 1, dropping all r=
eceived multicast packets in the nic (if supported by the hardware, of cour=
se)?

Background of the question:  I use an embedded system (currently with Linux=
 3.2.68) with a built-in nic (the FEC of a PowerPC MPC5200B) which supports=
 a mac hash filter.  As group E0000001 is enabled (BE; as reported by /proc=
/net/igmp), the nic's MAC hash filter is programmed to accept 01-00-5e-00-0=
0-01.  In one case, the device shall be operated in the same network as a b=
unch of Profinet/RT systems, producing a high level of traffic which unfort=
unately also matches the above mac hash.  This results in a high load on th=
e cpu, instead of dropping those packets in the nic.  As the system has a h=
ardware watchdog, this in turn causes the cpu being rebooted by the watchdo=
g regularly...  Thus removing this mac hash from the nic should be a remedy=
.

I didn't check what happens if I configure the kernel to completely disable=
 multicasting.  However, I would prefer to disable it from user-space, as t=
he system /might/ be used in an environment where multicasting is actually =
needed, and maintaining two different kernels is not a good idea imho.

Thanks in advance for any insight,
Albrecht.=

--=-5VN1rrKdQpsHdjeSgi1U
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iD8DBQBVJX06n/9unNAn/9ERAj7wAKCInK7CqBU4381I3GZ/yeiqql2A2ACgmio2
/q0AeeLKa7qbqvBvJXJoPwI=
=tgwZ
-----END PGP SIGNATURE-----

--=-5VN1rrKdQpsHdjeSgi1U--
