From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev 0/5] Switch drivers to d80211
Date: Sun, 23 Jul 2006 20:32:14 -0700
Message-ID: <200607232032.24299.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1296992.yLWpQiHPld";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:41958 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1751391AbWGXDyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Jul 2006 23:54:09 -0400
To: linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1296992.yLWpQiHPld
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,
	This patch series converts a number of fullmac wireless drivers to use=20
d80211.h instead of ieee80211.h. The changes are not major for the most par=
t=20
due to the fact that fullmac drivers tend to use the macros in ieee80211.h=
=20
more than any actual 802.11 stack functions.

Notes on individual drivers:
ray_cs: This change was quite small since ray_cs does not actually use=20
anything in ieee80211.h. Don't know why it includes it.. This change can=20
probably be brought over to wireless-2.6 if desired.
orinoco: Fairly straightforward. IEEE80211_DATA_LEN constant added to d8021=
1.h=20
because the value is also used in the stack.
wl3501_cs: Very simple.
zd1201: Straightforward.
airo: This was simple for the most part, but I added struct=20
ieee80211_info_element to d80211.h and updated the stack accordingly.

The remaining drivers are hostap, atmel, zd1211rw and ipw*. Hostap shouldn'=
t=20
be a problem, but I had the impression that a new d80211 version was=20
being/should be written. Atmel appears to implement its own softmac stack t=
o=20
some extent. Will need to investigate that further. zd1211rw utilizes=20
ieee80211softmac. Should work with d80211, though I haven't checked yet. An=
d=20
of course, there are the ipw drivers. They may require some modifications t=
o=20
d80211 to support some sort of kinda-softmac-but-not-really mode. :) I'll=20
figure it out when I get there..

=2DMichael Wu

--nextPart1296992.yLWpQiHPld
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBExD9IT3Oqt9AH4aERAkx0AJ91UXHrUm3mDl7geLcYbx435i/7HwCeLA//
BJl+2xr6rd8i2iWU1Rc58qA=
=OjLf
-----END PGP SIGNATURE-----

--nextPart1296992.yLWpQiHPld--
