From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#664064: linux-image-3.3.0-rc6-amd64: 4 messages every
 minute in syslog from netlink
Date: Sun, 18 Mar 2012 03:15:54 +0000
Message-ID: <1332040554.31699.22.camel@deadeye>
References: <20120315120008.14655.64028.reportbug@apollon>
	 <1331831653.3022.228.camel@deadeye> <4F622E92.9010007@gmx.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kHX8V6gWSxPPnkEfW4WG"
Cc: 664064@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Reinhard Karcher <reinhard.karcher@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57303 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751608Ab2CRDQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 23:16:06 -0400
In-Reply-To: <4F622E92.9010007@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kHX8V6gWSxPPnkEfW4WG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

[Please reply to all, not just to me.]

On Thu, 2012-03-15 at 19:01 +0100, Reinhard Karcher wrote:
> Am 15.03.2012 18:14, schrieb Ben Hutchings:
> > On Thu, 2012-03-15 at 13:00 +0100, Reinhard Karcher wrote:
> >> Package: linux-2.6
> >> Version: 3.3~rc6-1~experimental.1
> >> Severity: normal
> >>
> >> The kernel log says all!
> >> I have 2 laptops showing the messages, both amd64.
> >> One of them runs a 32-bit system in a VM with the linux-image-3.3.0-rc=
6-686-pae kernel,
> >> that does not have this problem.
> >> The amd64 kernel from unstable (3.2.0-2) does not show the messages.
> >>
> >> Reinhard
> >>
> >> -- Package-specific info:
> >> ** Version:
> >> Linux version 3.3.0-rc6-amd64 (Debian 3.3~rc6-1~experimental.1) (debia=
n-kernel@lists.debian.org) (gcc version 4.6.3 (Debian 4.6.3-1) ) #1 SMP Mon=
 Mar 5 20:53:11 UTC 2012
> >>
> >> ** Command line:
> >> BOOT_IMAGE=3D/boot/vmlinuz-3.3.0-rc6-amd64 root=3DUUID=3D9bb56ba6-3117=
-47d6-b07c-2cca477643e9 ro quiet cgroup_enable=3Dmemory
> >>
> >> ** Not tainted
> >>
> >> ** Kernel log:
> >> [46368.760279] netlink: 140 bytes leftover after parsing attributes.
[...]
> The same system, but using the kernel from unstable and not from=20
> experimental does not show the messages, so they are related to the=20
> experimetal kernel.
> Does this tell anything?
> root@apollon:/home/reinhard# lsof | grep netlink
> dnsmasq   1862     dnsmasq  mem       REG                8,2     24712=
=20
>    7391593 /usr/lib/libnfnetlink.so.0.2.0=20
>=20
> kded4     2839    reinhard  mem       REG                8,2     12272=
=20
>    9683029 /usr/lib/ntrack/modules/ntrack-rtnetlink.so=20

Well, netlink is a protocol, not a file.  But most programs using
netlink will probably use a library with 'netlink' or 'libnl' in its
name, so this does provide some clues.

[later:]
> Some further investigation showed that the 1st occurrence of the message=
=20
> is related to the start of KDE. After stopping X (and KDE) there are no=
=20
> new messages logged.

OK, so it's something running in your KDE session.  And the results you
got from lsof suggest that it's some kind of network monitor that's
hosted by kded4, using the ntrack library
<https://launchpad.net/ntrack>.  I've never heard of this before.

ntrack appearently has the option to use either libnl or its own
built-in netlink protocol code, and is using the latter on your system.
If you install ntrack-module-libnl-0 and remove
ntrack-module-rtnetlink-0, does this fix the problem?

Ben.

--=20
Ben Hutchings
Larkinson's Law: All laws are basically false.

--=-kHX8V6gWSxPPnkEfW4WG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT2VTaue/yOyVhhEJAQqekRAAsRKHnf1BaqyVZ3EKEU39ykrPkaDDDkaj
loZeb7alKCmaA98ynAJHBNt1xPspl7dxcUS5be6M8KRGcWzaKOVUhW0tYTf6Aoyx
C9il9Ja7dzkxYujIeyFIWxn5NH7FhwmNdh1CTz4vjBOT/LavAN+7e0mH+0QC9AJm
j/ykCzxStX4Y6hfdSqwHovZ5TeWhGBruc9Ch2h8hURonsCvVj6F5QVgsbzHIrE7K
UmBiIXPAsOJVhpr/LQQDwbftpDTpL9zfKCE4+Hfo+wFDSB9ETIDWoh316unTu6xr
Y922ItBmGZGj/i1rwXjqabjkmNhlOCB15o27qbVDFfqWEYEDfnB36JSHRObYX/lx
ZCRisfsxsPcJhpQPyS7LIf73V04YeQuXnjd6XYaaJf9/eDmqAz5p/JLtDTTX8hp6
/JLy6OaqJ+E4ymipJGtn6YKIgquFpHjC/1ZugINj1Yk3aD7lIGf8rBywUv8c2csz
fDlsIPLGWmoXY7Jp0M715whsojA66jWRd7z7dyIQlyeJX6MrORJwfUJOkEnV7cex
KzdEd3MVdDYrZ8rkvjDnieY537DmM1iHiWiZLMNnqIs0phWIJ7T8Dgvu4QV5/PfF
kfGKoCCBpY9Ye2p+uR7vumudbRAszKAGBIMQN4XWZIdnZTpRppY2m5GcCXqiDX6h
Q1bYsH4xF6A=
=+PVu
-----END PGP SIGNATURE-----

--=-kHX8V6gWSxPPnkEfW4WG--
