From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 30 Sep 2014 12:51:52 +1000
Message-ID: <20140930125152.7c005583@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Geg8Xt0dMPYe2yGXMSjmQOh"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	hayeswang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Geg8Xt0dMPYe2yGXMSjmQOh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/usb/r8152.c between commit 445f7f4d6262 ("r8152: fix the
carrier off when autoresuming") from the net tree and commit
b209af9981ee ("r8152: check code with checkpatch.pl") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/usb/r8152.c
index e0394427e372,a4d4c4a1354f..000000000000
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@@ -2067,10 -2080,11 +2097,10 @@@ static void rtl_disable(struct r8152 *t
  	for (i =3D 0; i < 1000; i++) {
  		if (ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR0) & TCR0_TX_EMPTY)
  			break;
- 		mdelay(1);
+ 		usleep_range(1000, 2000);
  	}
 =20
 -	for (i =3D 0; i < RTL8152_MAX_RX; i++)
 -		usb_kill_urb(tp->rx_info[i].urb);
 +	rtl_stop_rx(tp);
 =20
  	rtl8152_nic_reset(tp);
  }
@@@ -3131,12 -3211,13 +3229,13 @@@ static int rtl8152_resume(struct usb_in
  		} else {
  			tp->rtl_ops.up(tp);
  			rtl8152_set_speed(tp, AUTONEG_ENABLE,
- 				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
- 				DUPLEX_FULL);
+ 					  tp->mii.supports_gmii ?
+ 					  SPEED_1000 : SPEED_100,
+ 					  DUPLEX_FULL);
 +			tp->speed =3D 0;
 +			netif_carrier_off(tp->netdev);
 +			set_bit(WORK_ENABLE, &tp->flags);
  		}
 -		tp->speed =3D 0;
 -		netif_carrier_off(tp->netdev);
 -		set_bit(WORK_ENABLE, &tp->flags);
  		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
  	}
 =20

--Sig_/Geg8Xt0dMPYe2yGXMSjmQOh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUKhrOAAoJEMDTa8Ir7ZwVptUP/RVr+HasqmxxDaQOOd7b2mXx
eur8suEkEjML19nq0H1pOhA41nrPoODyUuC6GAq7XdHjfAoPATKLheupO3heLEL8
8wcn0QAu7FffSpJuocA79apRkw33I97DKHXXcY+rZ1VuUQwKCq2DJU+wdFDpV+Va
PUNvLxbSadaMr4hwzqEiplf4u3P2D3Uh7OvPNVbU6n8Wc3bCjv+a9vf16RUpJkJD
9SAuIMkvFdzE78RyxgxFp8zOqV6pySYykeRMIomcJ921HZnhUlGH5cBfYZjT2OQJ
ubUFvyUek2Rf4w3iofQYNlpk5k6vYPGMLxVkGKqamqG1U/ul5xgq2HqpqCJBHEZZ
7g+/1gQE7jouRPI56XIcBZFkJ5eiFFas/hXWwZXSac6MdT2SQhQl8dC//f4bPrJz
juU/g1qfXO4ZEpXClH6//dvX5IUKbE1n0GseyUyViHJNckDco/A35Jr5vR3X2j0z
cr3yHuxHvXBYe+MapZJL2zsdINoHZY56pvsudu4Jd5CgviKQVz8aX3QTMcBdn65q
wkVjfWfsz/zawgKOZlLfoGBhY/VuNEB9XiO1Huxr4rKtrxdBrSmVCVktlfPKN2Rg
lqkqpNk1RVLgS4NEW3cYGy3P4MU4xI2XNkdYvu1x1mTE7wnSrzOjsTxkzESvTf+K
zRqMHa24O6/ydUn/BcPd
=JhU5
-----END PGP SIGNATURE-----

--Sig_/Geg8Xt0dMPYe2yGXMSjmQOh--
