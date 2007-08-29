From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: Re: malformed captured packets
Date: Wed, 29 Aug 2007 18:22:34 +0200
Message-ID: <200708291822.35128.toralf.foerster@gmx.de>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D521BC.1050300@katalix.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5891985.H3IbvSZOlK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:51551 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757796AbXH2QWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 12:22:38 -0400
In-Reply-To: <46D521BC.1050300@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5891985.H3IbvSZOlK
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Mittwoch, 29. August 2007 schrieb James Chapman:

> Can you provide more information about the problem, please? Are you=20
> using a simple DSL modem with PPPoE, such that the ppp0 interface is=20
> that of the pppd started by a local PPPoE server? Is this a problem only=
=20
> with packet capture or are you seeing actual data corruption? Did this=20
> work with previous kernels? What is the network topology related to the=20
> DSL interface?
>=20

I use a ThinkPad T41 with this Ethernet controller:

n22 ~ # lspci | grep Eth
02:01.0 Ethernet controller: Intel Corporation 82540EP Gigabit Ethernet Con=
troller (Mobile) (rev 03)
02:02.0 Ethernet controller: Atheros Communications, Inc. AR5212 802.11abg =
NIC (rev 01)

My DSL provider is Alice DSL (formerly Hansenet) in Hamburg. The T41 is con=
nected
with an Ethernet cable to a Siemens DSL modem. The modem (just a modem, not=
 a
router) itself is connected to the DSL splitter which itself is plugged int=
o socket.

The current ppp version I'm using is net-dialup/ppp-2.4.4-r9

Here are my kernel config settings:

n22 ~ # zgrep PPP /proc/config.gz
CONFIG_PPP=3Dm
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPP_FILTER=3Dy
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
CONFIG_PPP_DEFLATE=3Dm
# CONFIG_PPP_BSDCOMP is not set
# CONFIG_PPP_MPPE is not set
CONFIG_PPPOE=3Dm

I observed this problem since a long time with different kernel versions (G=
entoo,
plain vanilla kernel, git sources) while playing with ethereal - currently =
known
as wireshark.

I'm wondering b/c for kscd eg. it is always the IP packet containing the co=
ntent
information of a CD (or even a <CD is unknown> message) with is struggled.
This packets prevents me from using the "Follow TCP Strem" feature of wires=
hark
for an easy look into the plain text of all TCP packets of this HTTP stream
(which was in fact the trigger for me to have a deeper look into the sniffed
stream from ppp0 and eth0).

=46or other apps I observed similar things which cannot fully be explained =
by
terms like "TCP checksum offloading".=20

I didn't observed any malfunction at application level so it might be an is=
sue
with the capturing itself.

Why is the ppp stream always ok in opposite to the eth0 stream ?

=2D-=20
MfG/Sincerely

Toralf F=F6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--nextPart5891985.H3IbvSZOlK
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBG1Z1LhyrlCH22naMRAu67AKC2y1xHSOFC38/R6lN9+zLqAAouGwCghKhR
alW4qJDMOxVEx/fWC9W/wmY=
=AGsZ
-----END PGP SIGNATURE-----

--nextPart5891985.H3IbvSZOlK--
