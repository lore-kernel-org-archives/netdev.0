From: Alfredo Beaumont Sainz <jtbbesaa@bipt106.bi.ehu.es>
Subject: Problems with Broadcom and Intel PRO/1000 cards
Date: Thu, 2 Jun 2005 12:38:19 +0200
Message-ID: <200506021238.25615.jtbbesaa@aintel.bi.ehu.es>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2076079.6N4Hu5pznk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart2076079.6N4Hu5pznk
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

I've a dual opteron machine with an integrated dual Broadcom 5704 10/100/10=
00=20
(tg3 driver) and an Intel PRO/1000 MT (e1000 driver). It seems that I canno=
t=20
make them work a Gbps. I've a crossover cable connecting a interface of the=
=20
Broadcom (eth1) with the Intel (eth2), but they connect at 100Mbps:

# /sbin/mii-tool -v

eth1: negotiated 100baseTx-FD, link ok
  product info: vendor 00:08:18, model 25 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
eth2: negotiated 100baseTx-FD, link ok
  product info: vendor 00:50:43, model 2 rev 5
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

As you can see, there's no 1000 FD advsertising. Forcing it with ethtool ma=
kes=20
them lose link connection:

# /usr/sbin/ethtool -s eth1 speed 1000 duplex full
# /sbin/mii-tool -v
eth1: no link
  product info: vendor 00:08:18, model 25 rev 0
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
eth2: no link
  product info: vendor 00:50:43, model 2 rev 5
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

After some secs link is recovered, at 100 again, and dmesg shows the follow=
ing=20
kernel messages:

tg3: eth1: Link is down.
e1000: eth2: e1000_watchdog: NIC Link is Down
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is off for TX and off for RX.
e1000: eth2: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex

According to the messages links would be at 1000 but they are not really. T=
he=20
same happens when forcing eth2.

I'm using kernel version 2.6.11.11 but it also happened with previous versi=
on=20
of the kernel.

Any hints? Thanks.
=2D-=20
Alfredo Beaumont. GPG: http://aintel.bi.ehu.es/~jtbbesaa/jtbbesaa.gpg.asc
Elektronika eta Telekomunikazioak Saila (Ingeniaritza Telematikoa)
Euskal Herriko Unibertsitatea, Bilbao (Basque Country). http://www.ehu.es

--nextPart2076079.6N4Hu5pznk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBCnuGh6KTU/EgLc1ERAgOsAJ9Bs8oPJEelifI+GtiP62cMEfl8ZQCfXxc6
e2z/CGhpOy0qWoXNj22/SMQ=
=4LuQ
-----END PGP SIGNATURE-----

--nextPart2076079.6N4Hu5pznk--
