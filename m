From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: generic 802.11 stack
Date: Tue, 7 Sep 2004 20:22:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409072022.14330.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409062132.49356.sam@errno.com> <20040906234701.511a8940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1168438.PPxzXlkP8u";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040906234701.511a8940.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart1168438.PPxzXlkP8u
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Dave,
I'd like to evaluate possibility to use your stack for real driver. 80211 h=
ave=20
some specifics thus we need to answer following questions:

=2D some devices handles almost all MAC in firmware; some - handle control =
frame=20
exchange in firmware, rest - on host; some use other separation of work=20
between host and firmware. So, quite flexible mechanism to specify offloadi=
ng=20
of parts of .11 stack to firmware required. What is best way?=20
netdev->features?

=2D there are cases when PHY information needed, to make decisions (like se=
lect=20
AP from list), or for information purposes (sniffer). What is your vision h=
ow=20
to do this? I.e. provide some standard PHY header before MAC header, out of=
=20
band (use cb?)
I see the following info that may be interesting:
rate;modulation;preamble;TSF timer;RSSI;antenna;signal;noise;AGC. This list=
=20
may vary from NIC to NIC.

=2D there is PHY level information that may be needed for Tx:
modulation;rate;retry policy and rates;Tx power;protection(RTS/CTS, CTS to=
=20
self). Same question as above: how to provide it?

=2D there is some interesting information that may come from Tx status, lik=
e=20
success indication, last rate, retry count, energy in channel after packet,=
=20
actual backoff time.

=2D is it feasible to do rate scaling in generic way in stack? Or should it=
 be=20
done always in the driver?

=2D Since WME and TGe introduction, NICs will likely to have multiple Tx qu=
eues.=20
It would be wise for driver to use multiple Tx queues and start/stop them=20
separately, like have all functions netif_start_queue() etc. have additiona=
l=20
parameter - queue number. Will it fit into your stack?

--nextPart1168438.PPxzXlkP8u
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBPe5Fqxdj7mhC6o0RAmd7AKCJKmxTQk6dRx2cnDaYQyiLoQ0USwCglzfj
aPOJ5j1um3UnBtf1NnS8H3w=
=JkZo
-----END PGP SIGNATURE-----

--nextPart1168438.PPxzXlkP8u--
