From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the bluetooth tree with Linus' tree
Date: Tue, 25 Oct 2011 17:25:09 +1100
Message-ID: <20111025172509.931831a5ad9ae3dab8fca562@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__25_Oct_2011_17_25_09_+1100_RCSxjPHuGjtwZXBB"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Moore <pmoore@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Andrei Emeltchenko <andrei.emeltchenko@intel.com>
To: "Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__25_Oct_2011_17_25_09_+1100_RCSxjPHuGjtwZXBB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Gustavo,

Today's linux-next merge of the bluetooth tree got a conflict in
net/bluetooth/l2cap_sock.c between commit 6230c9b4f895 ("bluetooth:
Properly clone LSM attributes to newly created child connections") from
Linus' tree and commit 15770b1ab974 ("Bluetooth: convert force_active
variable to flag in l2cap chan") from the bluetooth tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bluetooth/l2cap_sock.c
index e829236,836d12e..0000000
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@@ -931,12 -944,7 +946,9 @@@ static void l2cap_sock_init(struct soc
  		chan->max_tx =3D pchan->max_tx;
  		chan->tx_win =3D pchan->tx_win;
  		chan->sec_level =3D pchan->sec_level;
- 		chan->role_switch =3D pchan->role_switch;
- 		chan->force_reliable =3D pchan->force_reliable;
- 		chan->flushable =3D pchan->flushable;
- 		chan->force_active =3D pchan->force_active;
+ 		chan->flags =3D pchan->flags;
 +
 +		security_sk_clone(parent, sk);
  	} else {
 =20
  		switch (sk->sk_type) {

--Signature=_Tue__25_Oct_2011_17_25_09_+1100_RCSxjPHuGjtwZXBB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOplZFAAoJEECxmPOUX5FEgjsP+wfLQkTRW/iVuvDvHajKcV+y
FJpd3aVPJ62dP9hiswggUDoF1UTiynf9VkpeCPTsYTWlNeT/9lgykVLn/3HK72fp
04WSu8hK3QIgyOtqTBwolDkcQahaaaJtDvHb7PQIBky9+NW+ucPAGkd0E7lEdgtt
K31b+sUFNvlT1wUodXf+zcFNTUXfwBbo6wALWaY7hL+D+5sQX07kQ1zpqlqRuY5F
zTSEPAhdw2sjllYpEz3oT/eILykLilc9HDcplhzDqOTPT5P4NS8aOKO4i0McSXq4
E0YdhWvQLDMzmvDG6SDyci0ibi/q1gxHHLPjGqt+FbDJuLDA3atwgEoFhr/SjFeK
jtTVm/SLIyfmHfmcS6vSealoN6+2UVy2oGVfc58T41e2azYUUeD/HQsB3BneGO5g
rZ01rNnfO0hbPHoikUjiBr/rj2B0iWOs4B8zwoYEO89YoxyvxQZMoZG3LF88f+Qt
ZG442D4P1uHd2vVboIBqVTv2nTO0DdXCjAlmoZyJnsrWf/SAFyI+VcSi6G9+yNiw
EjOE7UYRe+dhRYYNUPJtudhoIVPhkpA857oc1xJETpNL3CBmOOIUOdDjMwRfrcgA
N86LFVt2JNQYIGn3yk9svVZFz4vitSbCTJJS4jNboHUUdPkO4zIA3EGF+YNN2y1O
2x2S9uKZxYJFTJM7hrb/
=xLtF
-----END PGP SIGNATURE-----

--Signature=_Tue__25_Oct_2011_17_25_09_+1100_RCSxjPHuGjtwZXBB--
