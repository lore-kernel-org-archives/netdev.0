From: Harald Welte <laforge@gnumonks.org>
Subject: [RFC] Options for ECN target
Date: Tue, 6 Aug 2002 08:35:41 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020806083541.L11828@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bzq2cJcN05fcPrs+"
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


--Bzq2cJcN05fcPrs+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

Some time ago I've written an ECN target for the iptables mangle table.=20
It has now undergone some final bugfixes and I intend to submit it to
the kernel.

The main goal of this target is to be able to selectively work around=20
known ECN blackholes rather than disabling ECN for the whole host using
"echo 0 > /proc/sys/net/ipv4/tcp_ecn".

There is one question left: How much flexibility do we want to give the use=
r?

The ECN target currently allows:

--ecn-tcp-remove	Remove CWR+ECE bits from TCP header. Should be used
			on TCP syn packets to prevent ECN negotiation

--ecn-ip-ect [0..3] 	Allows arbitrary setting of the ECT codepoint
--ecn-tcp-cwr [0|1]	Allows setting or clearing the TCP CWR bit
--ecn-tcp-ece [0|1]	Allows setting or clearing the TCP ECE bit


The first option is necessarry and is the primary use of the target.
The last three options are more experimental and would allow somebody
to play with 'simulated congestion' by setting the ECT in IP, etc.

However, this is potentially very dangerous and I'm not sure if it was
a good idea to give this power directly to the user. =20

Do you suggest removing the last three options and just keep the=20
--ecn-tcp-remove ?

Thanks for your assistance,

--=20
Live long and prosper
- Harald Welte / laforge@gnumonks.org               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
GCS/E/IT d- s-: a-- C+++ UL++++$ P+++ L++++$ E--- W- N++ o? K- w--- O- M+=
=20
V-- PS++ PE-- Y++ PGP++ t+ 5-- !X !R tv-- b+++ !DI !D G+ e* h--- r++ y+(*)

--Bzq2cJcN05fcPrs+
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9T246XaXGVTD0i/8RAhsAAJ42gv0vrnBq9eu9jb64krktAQ9GugCff58F
8M2WB1EKkDz337K3iAlFFQ8=
=z7Ku
-----END PGP SIGNATURE-----

--Bzq2cJcN05fcPrs+--
