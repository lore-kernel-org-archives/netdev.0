From: martin f krafft <madduck@madduck.net>
Subject: multiple default routes
Date: Mon, 19 May 2008 17:42:41 +0100
Message-ID: <20080519164241.GA14574@lapse.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8042706983866725345=="
Cc: netconf developers list <netconf-devel@lists.alioth.debian.org>
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org>
List-Unsubscribe: <http://lists.alioth.debian.org/mailman/listinfo/netconf-devel>,
	<mailto:netconf-devel-request@lists.alioth.debian.org?subject=unsubscribe>
List-Archive: <http://lists.alioth.debian.org/pipermail/netconf-devel>
List-Post: <mailto:netconf-devel@lists.alioth.debian.org>
List-Help: <mailto:netconf-devel-request@lists.alioth.debian.org?subject=help>
List-Subscribe: <http://lists.alioth.debian.org/mailman/listinfo/netconf-devel>,
	<mailto:netconf-devel-request@lists.alioth.debian.org?subject=subscribe>
Mime-version: 1.0
Sender: netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org
Errors-To: netconf-devel-bounces+glddn-netconf-devel=m.gmane.org@lists.alioth.debian.org
List-Id: netdev.vger.kernel.org


--===============8042706983866725345==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dear netdev wizards,

it used to be the case that adding a second default route broke
networking to the point where nothing gets routed through either of
the default routes anymore.

For a while now, I noticed that this isn't the case anymore, but
I can't isolate a behaviour that would have me believe that there's
a new default I can build on.

If I add a second default route (via a different gateway):

  default via 10.100.144.1 dev wifi=20
  default via 10.11.50.5 dev tun-rw-ul=20

then my old connections (via 10.11.50.5) die, new TCP connections
seem to go via 10.100.144.1, but ping does not seem to work:

when I tcpdump on iface 'any', I see e.g. two icmp echo-requests
leaving the machine and none coming back:

  $ sudo tcpdump -ni any icmp &
  $ ping -nc1 debian.org
  PING debian.org (192.25.206.10) 56(84) bytes of data.
  16:38:43.720951 IP 10.100.146.103 > 192.25.206.10: ICMP echo request, id =
52285, seq 1, length 64
  16:38:43.720978 IP 10.100.146.103 > 192.25.206.10: ICMP echo request, id =
52285, seq 1, length 64

  --- debian.org ping statistics ---
  1 packets transmitted, 0 received, 100% packet loss, time 0ms

If I hook tcpdump to the wifi iface, then I just get one packet
though, but still no replies.

Could someone please fill me in on the expected behaviour of Linux
2.6.18 and beyond when a second default route is added, or point me
to some documentation to read?

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
windows 2000: designed for the internet.
the internet: designed for unix.
=20
spamtraps: madduck.bogus@madduck.net

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIMa4BIgvIgzMMSnURAhMeAKCMraP02Zlt4/uFvtqpeVj+ZUTRbACeN10k
ebFoF4D1m/PFXf7LkTBxDYk=
=VhXf
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--


--===============8042706983866725345==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============8042706983866725345==--
