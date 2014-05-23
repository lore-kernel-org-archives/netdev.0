From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 23 May 2014 13:46:02 +1000
Message-ID: <20140523134602.4dac2f7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/cX6KlGT21T5VfHXOv/cexa="; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>,
	Veaceslav Falico <vfalico@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/cX6KlGT21T5VfHXOv/cexa=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/bonding/bond_alb.c between commit d0c21d43a5a1 ("bonding:
Send ALB learning packets using the right source") from the net tree
and commit 8557cd74ca8a ("bonding: replace SLAVE_IS_OK() with
bond_slave_can_tx()") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/bonding/bond_alb.c
index 93580a47cc54,03e0bcade234..000000000000
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@@ -1117,8 -1106,8 +1117,8 @@@ static void alb_fasten_mac_swap(struct=20
  	ASSERT_RTNL();
 =20
  	/* fasten the change in the switch */
- 	if (SLAVE_IS_OK(slave1)) {
+ 	if (bond_slave_can_tx(slave1)) {
 -		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
 +		alb_send_learning_packets(slave1, slave1->dev->dev_addr, false);
  		if (bond->alb_info.rlb_enabled) {
  			/* inform the clients that the mac address
  			 * has changed
@@@ -1129,8 -1118,8 +1129,8 @@@
  		disabled_slave =3D slave1;
  	}
 =20
- 	if (SLAVE_IS_OK(slave2)) {
+ 	if (bond_slave_can_tx(slave2)) {
 -		alb_send_learning_packets(slave2, slave2->dev->dev_addr);
 +		alb_send_learning_packets(slave2, slave2->dev->dev_addr, false);
  		if (bond->alb_info.rlb_enabled) {
  			/* inform the clients that the mac address
  			 * has changed

--Sig_/cX6KlGT21T5VfHXOv/cexa=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTfsR7AAoJEMDTa8Ir7ZwVI0QQAJTr9nAQ+Q86+HzYZ3ni4vJi
jR/U67DFNEFdcTNZ63lKgOume4weJT98x+/sLMNTeCJRJg00K1M63h34y1KL/41Q
wazjdX9ma+l1BtVBO2Bo4Hy9SZINZ5nuXrm3MCRqe0utn7KWAz0GBkZ2UA3fPC3h
QfsTk3vYa1Dnryq2NH3BPRJGFZcO0gxhCEkdzngnusteXzL6WygrQxB4aseegpIQ
0VvsU36oF8LzNxcfM0+lKlgHQpYioMw8a6lLIjdfG4dQSmjjpfaSLjKzenPfixMt
/Qr4KaxGL0l1s5uCxVcsK7aOPo2TsalM4OxIA2G/ObU2k2HFrO956JJSaBj1E04A
GWUdGrZnwleNpY7wxeUketrtVE6pWlvCEFB9XvFxhW6QIfWHZkGLro5N7dKlHDyE
0Hnkai15rC2RZrSe84DZXgkC4WZrw7OPQf5TjRWt/MInlh/SYus9TvV/C0RZWg/Y
p3JxcLpu3g+PjLQ+U+klYq307QsfmJOihDV9Y2lkiQtLhhYD63hexMWsvwzo4jGl
7ISBxZ9colBYp8ookSAJROfdxxqnrOoBFz0vEzScuFelCmXkgJ4w9R9iT4LnHZTn
WjAyjNMuQTcKWbrMXRexSXk8Cn/C/99bUHC2ogLOdzWIuavOPjE6FoJ1x9XzKoRL
frMXC9IV6MBLhC7FIDEF
=HtIo
-----END PGP SIGNATURE-----

--Sig_/cX6KlGT21T5VfHXOv/cexa=--
