From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Wed, 21 Dec 2011 22:59:56 +1100
Message-ID: <20111221225956.6db7ca8f0a620b234bc25001@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__21_Dec_2011_22_59_56_+1100_6pIWgGx/xmSmxB0a"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<francesco.gringoli@ing.unibs.it>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__21_Dec_2011_22_59_56_+1100_6pIWgGx/xmSmxB0a
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

[Resending to get through vger's address checks - sorry for duplicate]

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/b43/dma.c between commit 3db1cd5c05f3 ("net: fix
assignment of 0/1 to bool variables") from the net-next tree and commit
bad691946966 ("b43: avoid packet losses in the dma worker code") from the
wireless-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.

The newly created tx_queue_stopped array element assignments should be
changed form 0/1 to false/true as well (here and in main.c).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/b43/dma.c
index af23968,56d37dc..0000000
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@@ -1465,8 -1465,10 +1465,10 @@@ int b43_dma_tx(struct b43_wldev *dev, s
  	if ((free_slots(ring) < TX_SLOTS_PER_FRAME) ||
  	    should_inject_overflow(ring)) {
  		/* This TX ring is full. */
- 		ieee80211_stop_queue(dev->wl->hw, skb_get_queue_mapping(skb));
+ 		unsigned int skb_mapping =3D skb_get_queue_mapping(skb);
+ 		ieee80211_stop_queue(dev->wl->hw, skb_mapping);
+ 		dev->wl->tx_queue_stopped[skb_mapping] =3D 1;
 -		ring->stopped =3D 1;
 +		ring->stopped =3D true;
  		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
  			b43dbg(dev->wl, "Stopped TX ring %d\n", ring->index);
  		}
@@@ -1584,8 -1586,15 +1586,15 @@@ void b43_dma_handle_txstatus(struct b43
  	}
  	if (ring->stopped) {
  		B43_WARN_ON(free_slots(ring) < TX_SLOTS_PER_FRAME);
- 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
 -		ring->stopped =3D 0;
 +		ring->stopped =3D false;
+ 	}
+=20
+ 	if (dev->wl->tx_queue_stopped[ring->queue_prio]) {
+ 		dev->wl->tx_queue_stopped[ring->queue_prio] =3D 0;
+ 	} else {
+ 		/* If the driver queue is running wake the corresponding
+ 		 * mac80211 queue. */
+ 		ieee80211_wake_queue(dev->wl->hw, ring->queue_prio);
  		if (b43_debug(dev, B43_DBG_DMAVERBOSE)) {
  			b43dbg(dev->wl, "Woke up TX ring %d\n", ring->index);
  		}


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Wed__21_Dec_2011_22_59_56_+1100_6pIWgGx/xmSmxB0a
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO8co8AAoJEECxmPOUX5FEXOoP/jMw37mrQ2ITzFUDpOY8XS+w
pvF7FYy23juF6EhbGjA5wIcOlS9/zJoN4AXvNdST2DclF0orJaXQ+/1fqYzeJ38N
dCEjQSmmxGRtS55zb1H4ZxyJp2RD8fVW8yLv2SALhMmzLN5OchUzHlcj6+NyuthM
S9nB7pyLY/jod3eWQ1WnsYVT1to1P7lBYBpWw6++WCRP5W1S6SWvlRHyHIADThcF
kD4pK0qWtAxQca7kV8EqJLqXq4YL26Tu31oJOJHqe4LtuD9o8BgBbLYQGAeoxNEk
Ge9tcBehgtruPUMrNiM4cP7X2L8cLcpRrIc7TISz7arvM08EHyC29THL8owObm7c
xF7JyWmMsZBvrgSj485yavr8rD2ThsYGWgiq7rleP4L3J6UFkEg+Oe0Vh4kqlZwU
7R2iEP9AfIxuZmda8wztCigcNapxGv1Tjxywqv7/Ja7BMOZAoFQSK0PnnoLaQaRl
uRi41bH1LE5tzfIXFLhwr+zjTm3HCFutRaaIdfo+8eoGhFOy3mfqgvFLhJeXA5o7
FManOO8YSZHGaI2rum6pYGrBN68gdrlKCsVpPV7lnDoTaT697a0myZzQRb+t6T3x
0G2uYFVZthHPChEhSjLXheUj6mdymNsiP7DGWhOgFo6CJjqvk3kdC821ck8E7gat
P4FytXnBCOJzxs0vfyJd
=f78X
-----END PGP SIGNATURE-----

--Signature=_Wed__21_Dec_2011_22_59_56_+1100_6pIWgGx/xmSmxB0a--
