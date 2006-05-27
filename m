From: Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: [PATCH, 2.6.17-rc5-git3] ieee80211softmac_io.c: fix warning "defined but not used"
Date: Sat, 27 May 2006 11:04:18 +0200
Message-ID: <200605271104.21267.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1711307.AuTjLpf5FX";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.21]:5021 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751445AbWE0JEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 05:04:32 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1711307.AuTjLpf5FX
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Got this compiler warning and Johannes Berg <johannes@sipsolutions.net> wro=
te:

Yeah, known 'bug', we have that code there but never use it. Feel free
to submit a patch (to John Linville, CC netdev and softmac-dev) to
remove it.
=20
Signed-off-by: Toralf Foerster <toralf.foerster@gmx.de>

=2D-- src/net/ieee80211/softmac/ieee80211softmac_io.c_orig	2006-05-27 10:50=
:56.000000000 +0200
+++ src/net/ieee80211/softmac/ieee80211softmac_io.c	2006-05-27 10:51:45.000=
000000 +0200
@@ -440,47 +440,3 @@
 	return 0;
 }
=20
=2D
=2D/* Create an rts/cts frame */
=2Dstatic u32
=2Dieee80211softmac_rts_cts(struct ieee80211_hdr_2addr **pkt,
=2D	struct ieee80211softmac_device *mac, struct ieee80211softmac_network *n=
et,=20
=2D	u32 type)
=2D{
=2D	/* Allocate Packet */
=2D	(*pkt) =3D kmalloc(IEEE80211_2ADDR_LEN, GFP_ATOMIC);=09
=2D	memset(*pkt, 0, IEEE80211_2ADDR_LEN);
=2D	if((*pkt) =3D=3D NULL)
=2D		return 0;
=2D	ieee80211softmac_hdr_2addr(mac, (*pkt), type, net->bssid);
=2D	return IEEE80211_2ADDR_LEN;
=2D}
=2D
=2D
=2D/* Sends a control packet */
=2Dstatic int
=2Dieee80211softmac_send_ctl_frame(struct ieee80211softmac_device *mac,
=2D	struct ieee80211softmac_network *net, u32 type, u32 arg)
=2D{
=2D	void *pkt =3D NULL;
=2D	u32 pkt_size =3D 0;
=2D=09
=2D	switch(type) {
=2D	case IEEE80211_STYPE_RTS:
=2D	case IEEE80211_STYPE_CTS:
=2D		pkt_size =3D ieee80211softmac_rts_cts((struct ieee80211_hdr_2addr **)(=
&pkt), mac, net, type);
=2D		break;
=2D	default:
=2D		printkl(KERN_DEBUG PFX "Unsupported Control Frame type: %i\n", type);
=2D		return -EINVAL;
=2D	}
=2D
=2D	if(pkt_size =3D=3D 0)
=2D		return -ENOMEM;
=2D=09
=2D	/* Send the packet to the ieee80211 layer for tx */
=2D	ieee80211_tx_frame(mac->ieee, (struct ieee80211_hdr *) pkt, pkt_size);
=2D
=2D	kfree(pkt);
=2D	return 0;
=2D}

=2D-=20
MfG/Sincerely
Toralf F=F6rster

--nextPart1711307.AuTjLpf5FX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEeBYVhyrlCH22naMRAiVkAJ0XC9P6E4oZnKy0BFn7scyUgh8kQwCdHmW/
lVpmlh4XXGqIm+j9PbN7yII=
=/Q59
-----END PGP SIGNATURE-----

--nextPart1711307.AuTjLpf5FX--
