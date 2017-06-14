From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] Odd use of %14pM in net/batman-adv/distributed-arp-table.c
Date: Wed, 14 Jun 2017 10:23:38 +0200
Message-ID: <5300874.nPgxNW8UST@bentobox>
References: <1497390701.18751.26.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart4324963.WuPt3uYS2a"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: Joe Perches <joe@perches.com>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497390701.18751.26.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4324963.WuPt3uYS2a
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Dienstag, 13. Juni 2017 14:51:41 CEST Joe Perches wrote:
> An output mac address is 17 bytes
[...]
> but in net/batman-adv/distributed-arp-table.c
[...]
> %14pM is odd as this should not emit the last byte of the
> mac address.  So given the example above, it would output
> 00:11:22:33:44
[...]

I completely agree too the "wrong length" part. It is currently not omitting 
the last byte:

    Distributed ARP Table (bat0):
              IPv4             MAC        VID   last-seen
     *   10.204.28.206 e8:50:8b:8b:71:8d   -1      4:05
     *    10.204.77.54 6c:2f:2c:43:70:eb   -1      1:56
     *    10.25.21.138 ec:1f:72:c3:15:51   -1      4:21
     *   10.204.27.220 08:70:45:8c:ac:db   -1      2:32
     *   192.168.42.22 64:66:b3:bb:8e:ef   -1      0:18
     *     10.204.64.1 02:ba:7a:df:04:00   -1      0:00
     *   192.168.42.27 e8:de:27:f9:0f:48   -1      0:32

But it definitely also not "correct". I see something similar in the IV OGM
code:

    net/batman-adv/bat_iv_ogm.c:               "bidirectional: orig = %-15pM neigh = %-15pM => own_bcast = %2i, real recv = %2i, local tq: %3i, asym_penalty: %3i, iface_penalty: %3i, total tq: %3i, if_incoming = %s, if_outgoing = %s\n",

Do you want to provide a patch to convert it to simple %pM's?

Kind regards,
	Sven
--nextPart4324963.WuPt3uYS2a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAllA8ooACgkQXYcKB8Em
e0aMxw//aBh5BXDejVsBkFXF23awty4UIDnUq+fupMZFKKp0XWFNECCT5Sp70jWg
bHwsoNLKTPg3p4y/DQ36j0waOQcBFAepuDE3/2rZwM38jkxPMnM8gUIJlCZ+VIKD
1xxnid58CimH99CvNFsJ0XbmTW+hJ8WwX7vmM/ewb7qhmHzzlh9l6bwJppTtkSYh
XZqyXzoW5EOgJ2WOb42Wp85BXzAqlzaZN4yzWorJcYNTQmTNqJPuYgAuKiARb4Hi
0yJmAB0tsT4uOHlzXyhZ4LAXjvTXUG3PIrS/O6K+Hsp2zCDasqw/9OJyC+VHODlp
zAgshFbkN/eCCsFcO6HVghKOKFCvg87/bc7OsiKg824nUnS526b5unN7A6sOOlrH
baGJMek5Lq54HsLD2xhBILAMRfwZoRFQkAnlnkkAnfslcX3XgiQvWE9QUkxn1Ia3
+XSivc7T60wqaw5CARy7kfXLcxXJHwmLff1lQqDVEmdFbLaZsZMDBnlJmkyZYSwT
2D6ZiEybk9ly+KFL8NCyhObIirfKL2e3eLzpMGmgVfTHTcFs9wzw1u2D4oVqIvQP
2xBAd/hypoNpGNJgcENpXf6LJOuJyXPNeaLc/+ATNghgDYfDWX4Tjd8SwQnQA9t0
YUlwieCIknrs9CMr4d6WYvL6LR/alTQU7bpXnbaBR2oeiPbJhUc=
=Coc4
-----END PGP SIGNATURE-----

--nextPart4324963.WuPt3uYS2a--
