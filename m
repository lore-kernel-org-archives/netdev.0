From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#709616: floods the network with pause packets
Date: Sun, 26 May 2013 02:54:33 +0100
Message-ID: <1369533273.3469.301.camel@deadeye.wl.decadent.org.uk>
References: <20130524124059.12781.51344.reportbug@wencory.loria.fr>
	 <20130524160727.GM4752@decadent.org.uk> <51A07081.5010104@debian.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cxoou8aOVtoMP6WqPD+t"
Cc: 709616@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?St=E9phane?= Glondu <glondu@debian.org>,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47551 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758789Ab3EZByu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 21:54:50 -0400
In-Reply-To: <51A07081.5010104@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cxoou8aOVtoMP6WqPD+t
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-05-25 at 10:04 +0200, St=C3=A9phane Glondu wrote:
> Le 24/05/2013 18:07, Ben Hutchings a =C3=A9crit :
> >> With Linux 3.8, my computer starts (after some time) flooding its
> >> network interface with pause packets, effectively freezing it and
> >> other network-dependent computers connected to the same switch.

This is still the important issue, and regardless of whether pause
frames are being handled properly it sounds like the hardware RX path
may be locking up and that causes it to generate them continuously.  I
don't know how to investigate that, so this message is going to the
e1000e developers.

> > Switches should normally be configured to generate but not respond
> > to pause frames.  I don't know how unmanaged switches are typically
> > configured.  What do ethtool (no options and 'ethtool -a' report for
> > this device?
>=20
> The other frozen computers are connected via an unmanaged switch.
>=20
> # ethtool eth0
> Settings for eth0:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Supported pause frame use: No
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Advertised pause frame use: No
>         Advertised auto-negotiation: Yes

I forgot, e1000e still doesn't report autoneg state completely through
ethtool.  How about 'mii-tool -v eth0'?

>         Speed: 100Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 2
>         Transceiver: internal
>         Auto-negotiation: on
>         MDI-X: off
>         Supports Wake-on: pumbg
>         Wake-on: g
>         Current message level: 0x00000001 (1)
>                                drv
>         Link detected: yes
> # ethtool -a eth0
> Pause parameters for eth0:
> Autonegotiate:  on
> RX:             on
> TX:             on
>=20
> >> When I connect directly my laptop to the computer, and run tcpdump on
> >> the laptop, I see:
> >> [...]
> > There seems to be a bug in your laptop's network driver, because pause
> > frames should not be passed to the kernel.  (Usually they are
> > discarded by the MAC.)
>=20
> Even in promiscuous mode?
[...]

MAC control frames, which include pause frames, should never be passed
to the host (specified in IEEE 802.3 clause 31.3).  In case the hardware
still delivers them to the host, it's the driver's responsibility to
discard them.  This is the same as for frames that have an error at the
Ethernet level, e.g. bad CRC.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-cxoou8aOVtoMP6WqPD+t
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUaFrWee/yOyVhhEJAQqteA//em6ah7ttJYXVgHZK3oTVQ3cOSmEnHkZK
SXxApBtxqZjG7ExNvHcvhdxqQEFSrwK39+6dMyRfM5dmK3Kk7iURbvxL0DWJrbg0
1Y41UU8opvOY5Qhh7IJI/sTvAhmqFTqdmKsHGFTO8EBh5vLQjEGqaa1v+eSMGSQ1
d184uaGO1HXXYDBOUfwAyKtnKNOxLex07zm9RhhKNOYmTdqgU3/DU9ejsySGrGcE
f06UXxMtuEvApuKwALL0HJdHl9NSeS6wTr89eHVdwwWY+yKwoKPTTdGVeayCBpM6
9xLwg9N4PwdSKnJCD8Ui6dK0F0Ol5NH5es/KWVsPQsyQBf2nTJXrccUUs/bsM7BS
xn2ApDnQAzho71HGbZyUoXBGBayy9i96fpLCAzSYF78LxTw/2ayX9bPQ4lrpu3PL
Blfz32bsUVeRR1fbfg+2zYq/ufj6/zsXqfcLX9TMrXp8Ei4IxvE5IG/7Y424ASgD
NUl8lbAc3RLVY7dQOvW4vKyPs1Q664ibGCGVkd9XXs5XjQIBLVUPgdXHasppppYh
SbpHD72rT+bCbRnoWLzOciiWF1MjAi0ERypLtAZuMrjxKkd65wRHztQ/gjxHBRRC
1bYAJxyrGSwI8Uq8dlDfg9t6q2YwpMDUrouGVS9D5FO38DO0evSVykJh6Hj4V5F6
C+/u48iLyyo=
=THxJ
-----END PGP SIGNATURE-----

--=-cxoou8aOVtoMP6WqPD+t--
