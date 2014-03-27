From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Thu, 27 Mar 2014 16:09:38 +1100
Message-ID: <20140327160938.c1a4f9a5df6f93e17b55d3cd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__27_Mar_2014_16_09_38_+1100_CMGZeHkUr32E=NVT"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mathieu Maret <mathieu.maret@gmail.com>,
	Jelena Bjelja <jelena.bjelja.ing@gmail.com>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__27_Mar_2014_16_09_38_+1100_CMGZeHkUr32E=NVT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/wlags49_h2/wl_netdev.c between commit 8d4ade284a41
("wlags49_h2: Call dev_kfree/consume_skb_any instead of dev_kfree_skb")
from the net-next tree and commit fed3ffd8f7ef ("staging: wlags49_h2:
reindent wl_netdev.c") (and maybe others) from the staging tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/staging/wlags49_h2/wl_netdev.c
index 69bc0a01ae14,77e4be21e44b..000000000000
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@@ -626,103 -605,105 +605,105 @@@ void wl_tx_timeout(struct net_device *d
   *      1 on error
   *
   ************************************************************************=
******/
- int wl_send( struct wl_private *lp )
+ int wl_send(struct wl_private *lp)
  {
 =20
-     int                 status;
-     DESC_STRCT          *desc;
-     WVLAN_LFRAME        *txF =3D NULL;
-     struct list_head    *element;
-     int                 len;
+ 	int status;
+ 	DESC_STRCT *desc;
+ 	WVLAN_LFRAME *txF =3D NULL;
+ 	struct list_head *element;
+ 	int len;
      /*-------------------------------------------------------------------=
-----*/
 =20
-     if( lp =3D=3D NULL ) {
-         DBG_ERROR( DbgInfo, "Private adapter struct is NULL\n" );
-         return FALSE;
-     }
-     if( lp->dev =3D=3D NULL ) {
-         DBG_ERROR( DbgInfo, "net_device struct in wl_private is NULL\n" );
-         return FALSE;
-     }
-=20
-     /* Check for the availability of FIDs; if none are available, don't t=
ake any
-        frames off the txQ */
-     if( lp->hcfCtx.IFB_RscInd =3D=3D 0 ) {
-         return FALSE;
-     }
-=20
-     /* Reclaim the TxQ Elements and place them back on the free queue */
-     if( !list_empty( &( lp->txQ[0] ))) {
-         element =3D lp->txQ[0].next;
-=20
-         txF =3D (WVLAN_LFRAME * )list_entry( element, WVLAN_LFRAME, node =
);
-         if( txF !=3D NULL ) {
-             lp->txF.skb  =3D txF->frame.skb;
-             lp->txF.port =3D txF->frame.port;
-=20
-             txF->frame.skb  =3D NULL;
-             txF->frame.port =3D 0;
-=20
-             list_del( &( txF->node ));
-             list_add( element, &( lp->txFree ));
-=20
-             lp->txQ_count--;
-=20
-             if( lp->txQ_count < TX_Q_LOW_WATER_MARK ) {
-                 if( lp->netif_queue_on =3D=3D FALSE ) {
-                     DBG_TX( DbgInfo, "Kickstarting Q: %d\n", lp->txQ_coun=
t );
-                     netif_wake_queue( lp->dev );
-                     WL_WDS_NETIF_WAKE_QUEUE( lp );
-                     lp->netif_queue_on =3D TRUE;
-                 }
-             }
-         }
-     }
-=20
-     if( lp->txF.skb =3D=3D NULL ) {
-         return FALSE;
-     }
-=20
-     /* If the device has resources (FIDs) available, then Tx the packet */
-     /* Format the TxRequest and send it to the adapter */
-     len =3D lp->txF.skb->len < ETH_ZLEN ? ETH_ZLEN : lp->txF.skb->len;
-=20
-     desc                    =3D &( lp->desc_tx );
-     desc->buf_addr          =3D lp->txF.skb->data;
-     desc->BUF_CNT           =3D len;
-     desc->next_desc_addr    =3D NULL;
-=20
-     status =3D hcf_send_msg( &( lp->hcfCtx ), desc, lp->txF.port );
-=20
-     if( status =3D=3D HCF_SUCCESS ) {
-         lp->dev->trans_start =3D jiffies;
-=20
-         DBG_TX( DbgInfo, "Transmit...\n" );
-=20
-         if( lp->txF.port =3D=3D HCF_PORT_0 ) {
-             lp->stats.tx_packets++;
-             lp->stats.tx_bytes +=3D lp->txF.skb->len;
-         }
+ 	if (lp =3D=3D NULL) {
+ 		DBG_ERROR(DbgInfo, "Private adapter struct is NULL\n");
+ 		return FALSE;
+ 	}
+ 	if (lp->dev =3D=3D NULL) {
+ 		DBG_ERROR(DbgInfo, "net_device struct in wl_private is NULL\n");
+ 		return FALSE;
+ 	}
+=20
+ 	/*
+ 	 * Check for the availability of FIDs; if none are available,
+ 	 * don't take any frames off the txQ
+ 	 */
+ 	if (lp->hcfCtx.IFB_RscInd =3D=3D 0)
+ 		return FALSE;
+=20
+ 	/* Reclaim the TxQ Elements and place them back on the free queue */
+ 	if (!list_empty(&(lp->txQ[0]))) {
+ 		element =3D lp->txQ[0].next;
+=20
+ 		txF =3D (WVLAN_LFRAME *) list_entry(element, WVLAN_LFRAME, node);
+ 		if (txF !=3D NULL) {
+ 			lp->txF.skb =3D txF->frame.skb;
+ 			lp->txF.port =3D txF->frame.port;
+=20
+ 			txF->frame.skb =3D NULL;
+ 			txF->frame.port =3D 0;
+=20
+ 			list_del(&(txF->node));
+ 			list_add(element, &(lp->txFree));
+=20
+ 			lp->txQ_count--;
+=20
+ 			if (lp->txQ_count < TX_Q_LOW_WATER_MARK) {
+ 				if (lp->netif_queue_on =3D=3D FALSE) {
+ 					DBG_TX(DbgInfo, "Kickstarting Q: %d\n",
+ 					       lp->txQ_count);
+ 					netif_wake_queue(lp->dev);
+ 					WL_WDS_NETIF_WAKE_QUEUE(lp);
+ 					lp->netif_queue_on =3D TRUE;
+ 				}
+ 			}
+ 		}
+ 	}
+=20
+ 	if (lp->txF.skb =3D=3D NULL)
+ 		return FALSE;
+=20
+ 	/* If the device has resources (FIDs) available, then Tx the packet */
+ 	/* Format the TxRequest and send it to the adapter */
+ 	len =3D lp->txF.skb->len < ETH_ZLEN ? ETH_ZLEN : lp->txF.skb->len;
+=20
+ 	desc =3D &(lp->desc_tx);
+ 	desc->buf_addr =3D lp->txF.skb->data;
+ 	desc->BUF_CNT =3D len;
+ 	desc->next_desc_addr =3D NULL;
+=20
+ 	status =3D hcf_send_msg(&(lp->hcfCtx), desc, lp->txF.port);
+=20
+ 	if (status =3D=3D HCF_SUCCESS) {
+ 		lp->dev->trans_start =3D jiffies;
+=20
+ 		DBG_TX(DbgInfo, "Transmit...\n");
 =20
+ 		if (lp->txF.port =3D=3D HCF_PORT_0) {
+ 			lp->stats.tx_packets++;
+ 			lp->stats.tx_bytes +=3D lp->txF.skb->len;
+ 		}
  #ifdef USE_WDS
-         else
-         {
-             lp->wds_port[(( lp->txF.port >> 8 ) - 1)].stats.tx_packets++;
-             lp->wds_port[(( lp->txF.port >> 8 ) - 1)].stats.tx_bytes +=3D=
 lp->txF.skb->len;
-         }
+ 		else {
+ 			lp->wds_port[((lp->txF.port >> 8) -
+ 				      1)].stats.tx_packets++;
+ 			lp->wds_port[((lp->txF.port >> 8) -
+ 				      1)].stats.tx_bytes +=3D lp->txF.skb->len;
+ 		}
 =20
- #endif  /* USE_WDS */
+ #endif /* USE_WDS */
 =20
-         /* Free the skb and perform queue cleanup, as the buffer was
-             transmitted successfully */
-         dev_consume_skb_any( lp->txF.skb );
+ 		/* Free the skb and perform queue cleanup, as the buffer was
+ 		   transmitted successfully */
 -		dev_kfree_skb(lp->txF.skb);
++		dev_consume_skb_any(lp->txF.skb);
 =20
-         lp->txF.skb =3D NULL;
-         lp->txF.port =3D 0;
-     }
+ 		lp->txF.skb =3D NULL;
+ 		lp->txF.port =3D 0;
+ 	}
+=20
+ 	return TRUE;
+ }				/* wl_send */
 =20
-     return TRUE;
- } // wl_send
  /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D*/
 =20
  /************************************************************************=
*******
@@@ -1695,70 -1715,71 +1715,71 @@@ void wl_wds_netif_carrier_off(struct wl
   *      1 on error
   *
   ************************************************************************=
******/
- int wl_send_dma( struct wl_private *lp, struct sk_buff *skb, int port )
+ int wl_send_dma(struct wl_private *lp, struct sk_buff *skb, int port)
  {
-     int         len;
-     DESC_STRCT *desc =3D NULL;
-     DESC_STRCT *desc_next =3D NULL;
+ 	int len;
+ 	DESC_STRCT *desc =3D NULL;
+ 	DESC_STRCT *desc_next =3D NULL;
      /*-------------------------------------------------------------------=
-----*/
 =20
-     if( lp =3D=3D NULL ) {
-         DBG_ERROR( DbgInfo, "Private adapter struct is NULL\n" );
-         return FALSE;
-     }
+ 	if (lp =3D=3D NULL) {
+ 		DBG_ERROR(DbgInfo, "Private adapter struct is NULL\n");
+ 		return FALSE;
+ 	}
 =20
-     if( lp->dev =3D=3D NULL ) {
-         DBG_ERROR( DbgInfo, "net_device struct in wl_private is NULL\n" );
-         return FALSE;
-     }
+ 	if (lp->dev =3D=3D NULL) {
+ 		DBG_ERROR(DbgInfo, "net_device struct in wl_private is NULL\n");
+ 		return FALSE;
+ 	}
 =20
-     /* AGAIN, ALL THE QUEUEING DONE HERE IN I/O MODE IS NOT PERFORMED */
+ 	/* AGAIN, ALL THE QUEUEING DONE HERE IN I/O MODE IS NOT PERFORMED */
 =20
-     if( skb =3D=3D NULL ) {
-         DBG_WARNING (DbgInfo, "Nothing to send.\n");
-         return FALSE;
-     }
+ 	if (skb =3D=3D NULL) {
+ 		DBG_WARNING(DbgInfo, "Nothing to send.\n");
+ 		return FALSE;
+ 	}
 =20
-     len =3D skb->len;
+ 	len =3D skb->len;
 =20
-     /* Get a free descriptor */
-     desc =3D wl_pci_dma_get_tx_packet( lp );
+ 	/* Get a free descriptor */
+ 	desc =3D wl_pci_dma_get_tx_packet(lp);
 =20
-     if( desc =3D=3D NULL ) {
-         if( lp->netif_queue_on =3D=3D TRUE ) {
-             netif_stop_queue( lp->dev );
-             WL_WDS_NETIF_STOP_QUEUE( lp );
-             lp->netif_queue_on =3D FALSE;
+ 	if (desc =3D=3D NULL) {
+ 		if (lp->netif_queue_on =3D=3D TRUE) {
+ 			netif_stop_queue(lp->dev);
+ 			WL_WDS_NETIF_STOP_QUEUE(lp);
+ 			lp->netif_queue_on =3D FALSE;
 =20
-             dev_kfree_skb_any( skb );
-             return 0;
-         }
-     }
 -			dev_kfree_skb(skb);
++			dev_kfree_skb_any(skb);
+ 			return 0;
+ 		}
+ 	}
+=20
+ 	SET_BUF_CNT(desc, /*HCF_DMA_FD_CNT */ HFS_ADDR_DEST);
+ 	SET_BUF_SIZE(desc, HCF_DMA_TX_BUF1_SIZE);
 =20
-     SET_BUF_CNT( desc, /*HCF_DMA_FD_CNT*/HFS_ADDR_DEST );
-     SET_BUF_SIZE( desc, HCF_DMA_TX_BUF1_SIZE );
+ 	desc_next =3D desc->next_desc_addr;
 =20
-     desc_next =3D desc->next_desc_addr;
+ 	if (desc_next->buf_addr =3D=3D NULL) {
+ 		DBG_ERROR(DbgInfo, "DMA descriptor buf_addr is NULL\n");
+ 		return FALSE;
+ 	}
 =20
-     if( desc_next->buf_addr =3D=3D NULL ) {
-         DBG_ERROR( DbgInfo, "DMA descriptor buf_addr is NULL\n" );
-         return FALSE;
-     }
+ 	/* Copy the payload into the DMA packet */
+ 	memcpy(desc_next->buf_addr, skb->data, len);
 =20
-     /* Copy the payload into the DMA packet */
-     memcpy( desc_next->buf_addr, skb->data, len );
+ 	SET_BUF_CNT(desc_next, len);
+ 	SET_BUF_SIZE(desc_next, HCF_MAX_PACKET_SIZE);
 =20
-     SET_BUF_CNT( desc_next, len );
-     SET_BUF_SIZE( desc_next, HCF_MAX_PACKET_SIZE );
+ 	hcf_dma_tx_put(&(lp->hcfCtx), desc, 0);
 =20
-     hcf_dma_tx_put( &( lp->hcfCtx ), desc, 0 );
+ 	/* Free the skb and perform queue cleanup, as the buffer was
+ 	   transmitted successfully */
 -	dev_kfree_skb(skb);
++	dev_consume_skb_any(skb);
 =20
-     /* Free the skb and perform queue cleanup, as the buffer was
-             transmitted successfully */
-     dev_consume_skb_any( skb );
+ 	return TRUE;
+ }				/* wl_send_dma */
 =20
-     return TRUE;
- } // wl_send_dma
  /*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D*/
 =20
  /************************************************************************=
*******

--Signature=_Thu__27_Mar_2014_16_09_38_+1100_CMGZeHkUr32E=NVT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTM7KYAAoJEMDTa8Ir7ZwVpfUP/i31nt6/5bZEY/VhP1jQz1wC
Taxs1nina7P7LHp3ujHgO5otUJgHA0HoUDfpBM/ubmWb5hSOlv8UUo+d4IS4a8ET
B4gzjzhsT7+JE3jRmTTntNRd5YxkfDPBkjT53RqZtwJvqCx3MW7CkovnCnqYE2Ck
dB0Wwy8nK/PtyorXPqx/c14cutwMZwwW1XyMQx7hp5GF8n7jT/YMSOYvB+ETxYrd
eNDNbmJxhJfBikNPCV4XpBIE+X6tWE6GUO8gG7HQe5TqNb0S9CHeIEtaTXdSHtP9
SiwO43A7Fp11Wtm3gz+VTJdOQfk0OwQ3ktzshOhL61Hb8KAFFwA1pdctAvjPcGPv
KRiUpA4+cA03V/b1Ntzo5Mmxs1iEn2nat40cpUyje4NtXaV7mjOrXzGbhmixmS+U
mRA7cEWPYoFBC5BhIk2ktrSHInT8lUNalx4tX4eSESBvJFTjC9CqJYAZZUHN+Evh
9TeYgNEP0QYNz32ZKBIAl4efETZ0MyZoF7+bgTAO/gyfXAA0O+iSGQdfQqsJkaDM
hTYxcQCI3xG/zMDxY1/WTyzGE0D9gtSVb5BeoV51eKEft31vO/89n0ftlpxUmkoY
N2FVziF8XC6QjVArcreCDxmMtIlohH1T/6H512sWcwXAnwpTrY0/7wmLdFP3cnlo
7mxveU/oik9e6J3Hx8hr
=OItY
-----END PGP SIGNATURE-----

--Signature=_Thu__27_Mar_2014_16_09_38_+1100_CMGZeHkUr32E=NVT--
