From: Pavel Machek <pavel@denx.de>
Subject: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related pauses.
Date: Thu, 24 Nov 2016 11:36:30 +0100
Message-ID: <20161124103630.GB27793@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124102901.GA27793@amd>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="JP+T4n/bALQSJXh8"
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        kernel list <linux-kernel@vger.kernel.org>,
        ezequiel@vanguardiasur.com.ar, sonic.zhang@analog.com,
        fabrice.gasnier@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124102901.GA27793@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--JP+T4n/bALQSJXh8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> What is going on with all these likely()s? Likely new hardware owners
> will not be happy... or anyone running a lot of jumbo frames. (Perhaps
> CPU's branch prediction can do better job here, without explicit hints?)
>=20
>      if (unlikely(is_jumbo) && likely(priv->synopsys_id <
>                                               DWMAC_CORE_4_00)) {

    Fix english, remove misleading unlikely's.

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index e5a5a05..0363db3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2003,7 +2003,7 @@ static netdev_tx_t stmmac_tso_xmit(struct sk_buff *sk=
b, struct net_device *dev)
 	/* Compute header lengths */
 	proto_hdr_len =3D skb_transport_offset(skb) + tcp_hdrlen(skb);
=20
-	/* Desc availability based on threshold should be enough safe */
+	/* Desc availability based on threshold should be safe enough */
 	if (unlikely(stmmac_tx_avail(priv) <
 		(((skb->len - proto_hdr_len) / TSO_MAX_BUFF_SIZE + 1)))) {
 		if (!netif_queue_stopped(dev)) {
@@ -2216,8 +2216,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	if (enh_desc)
 		is_jumbo =3D priv->hw->mode->is_jumbo_frm(skb->len, enh_desc);
=20
-	if (unlikely(is_jumbo) && likely(priv->synopsys_id <
-					 DWMAC_CORE_4_00)) {
+	if (unlikely(is_jumbo) && priv->synopsys_id < DWMAC_CORE_4_00) {
 		entry =3D priv->hw->mode->jumbo_frm(priv, skb, csum_insertion);
 		if (unlikely(entry < 0))
 			goto dma_map_err;
@@ -2242,7 +2241,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
=20
 		priv->tx_skbuff[entry] =3D NULL;
=20
-		if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00)) {
+		if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
 			desc->des0 =3D des;
 			priv->tx_skbuff_dma[entry].buf =3D desc->des0;
 		} else {
@@ -2319,7 +2318,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 		if (dma_mapping_error(priv->device, des))
 			goto dma_map_err;
=20
-		if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00)) {
+		if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
 			first->des0 =3D des;
 			priv->tx_skbuff_dma[first_entry].buf =3D first->des0;
 		} else {
@@ -2438,7 +2437,7 @@ static inline void stmmac_rx_refill(struct stmmac_pri=
v *priv)
 				break;
 			}
=20
-			if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00)) {
+			if (priv->synopsys_id >=3D DWMAC_CORE_4_00) {
 				p->des0 =3D priv->rx_skbuff_dma[entry];
 				p->des1 =3D 0;
 			} else {
@@ -2455,7 +2454,7 @@ static inline void stmmac_rx_refill(struct stmmac_pri=
v *priv)
 		}
 		wmb();
=20
-		if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00))
+		if (priv->synopsys_id >=3D DWMAC_CORE_4_00)
 			priv->hw->desc->init_rx_desc(p, priv->use_riwt, 0, 0);
 		else
 			priv->hw->desc->set_rx_owner(p);
@@ -2545,7 +2544,7 @@ static int stmmac_rx(struct stmmac_priv *priv, int li=
mit)
 			int frame_len;
 			unsigned int des;
=20
-			if (unlikely(priv->synopsys_id >=3D DWMAC_CORE_4_00))
+			if (priv->synopsys_id >=3D DWMAC_CORE_4_00)
 				des =3D p->des0;
 			else
 				des =3D p->des2;


--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--JP+T4n/bALQSJXh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg2wq4ACgkQMOfwapXb+vKOvACfTRzBzIVmetbZ/NxfVJmCh7O7
ZAwAn2O+UV+o85X0XpzfiXh8XKq1kVQo
=AugX
-----END PGP SIGNATURE-----

--JP+T4n/bALQSJXh8--
