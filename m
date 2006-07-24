From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 4/5] zd1201: Switch to d80211.h
Date: Sun, 23 Jul 2006 20:48:04 -0700
Message-ID: <200607232048.09687.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3357409.HhbBzLdcnS";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org, pe1rxq@amsat.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:43494 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751394AbWGXDyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:10 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3357409.HhbBzLdcnS
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

zd1201: Switch to d80211.h

This patch "converts" the zd1201 driver to use d80211.h instead
of ieee80211.h

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/zd1201.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 662ecc8..c08557a 100644
=2D-- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -21,7 +21,7 @@ #include <net/iw_handler.h>
 #include <linux/string.h>
 #include <linux/if_arp.h>
 #include <linux/firmware.h>
=2D#include <net/ieee80211.h>
+#include <net/d80211.h>
 #include "zd1201.h"
=20
 static struct usb_device_id zd1201_table[] =3D {
@@ -338,14 +338,14 @@ static void zd1201_usbrx(struct urb *urb
 			goto resubmit;
 		}
 		=09
=2D		if ((seq & IEEE80211_SCTL_FRAG) ||
=2D		    (fc & IEEE80211_FCTL_MOREFRAGS)) {
+		if (WLAN_GET_SEQ_FRAG(seq) ||
+		    (fc & WLAN_FC_MOREFRAG)) {
 			struct zd1201_frag *frag =3D NULL;
 			char *ptr;
=20
 			if (datalen<14)
 				goto resubmit;
=2D			if ((seq & IEEE80211_SCTL_FRAG) =3D=3D 0) {
+			if (WLAN_GET_SEQ_FRAG(seq) =3D=3D 0) {
 				frag =3D kmalloc(sizeof(*frag), GFP_ATOMIC);
 				if (!frag)
 					goto resubmit;
@@ -355,7 +355,7 @@ static void zd1201_usbrx(struct urb *urb
 					goto resubmit;
 				}
 				frag->skb =3D skb;
=2D				frag->seq =3D seq & IEEE80211_SCTL_SEQ;
+				frag->seq =3D WLAN_GET_SEQ_SEQ(seq);
 				skb_reserve(skb, 2);
 				memcpy(skb_put(skb, 12), &data[datalen-14], 12);
 				memcpy(skb_put(skb, 2), &data[6], 2);
@@ -364,7 +364,7 @@ static void zd1201_usbrx(struct urb *urb
 				goto resubmit;
 			}
 			hlist_for_each_entry(frag, node, &zd->fraglist, fnode)
=2D				if (frag->seq =3D=3D (seq&IEEE80211_SCTL_SEQ))
+				if (frag->seq =3D=3D WLAN_GET_SEQ_SEQ(seq))
 					break;
 			if (!frag)
 				goto resubmit;
@@ -372,7 +372,7 @@ static void zd1201_usbrx(struct urb *urb
 			ptr =3D skb_put(skb, len);
 			if (ptr)
 				memcpy(ptr, data+8, len);
=2D			if (fc & IEEE80211_FCTL_MOREFRAGS)
+			if (fc & WLAN_FC_MOREFRAG)
 				goto resubmit;
 			hlist_del_init(&frag->fnode);
 			kfree(frag);

--nextPart3357409.HhbBzLdcnS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExEL5T3Oqt9AH4aERAif/AJ9/GQWGcpST9d07Wzn5TuJ43fWbqwCguPCe
tHgHas6m3zWKfiF5xrIiNZ0=
=SWbO
-----END PGP SIGNATURE-----

--nextPart3357409.HhbBzLdcnS--
