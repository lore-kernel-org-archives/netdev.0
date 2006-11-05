From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 0/11] convert d80211 to a proper protocol
Date: Sun, 05 Nov 2006 16:39:34 +0100
Message-ID: <1162741174.24574.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-/BB6FCSc05L2gPW4WHpW"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:33478 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932699AbWKEPlC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 10:41:02 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/BB6FCSc05L2gPW4WHpW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

I figured I'd look how hard it actually was to convert d80211 to a
proper protocol. And contrary to my own expectations I succeeded in
doing that in just over a day. Just like 8021q, it has virtual devices.

The patchset is huge and can be found at
http://johannes.sipsolutions.net/files/d80211-proto/

John, please apply patches 001 and 002 out of the patchset as soon as
you can -- they fix issues with cfg80211 that came up on IRC and in
private mail to me. Very important, and not related to converting it to
a protocol.

Each patch comes with a subject and description but since they're large
let me discuss some bits here.

001-cfg80211-fix-Makefile.patch
   cfg80211: fix Makefile brokenness

002-cfg80211-wext-compat.patch
   cfg80211: fix WE compat code

Absolutely required to fix two issues with cfg80211 that make the
current tree usable only in the strange configuration WE_NETLINK on and
CFG80211 off.

003-d80211-cookie.patch
   d80211: change the cookie to be opaque

   This changes the 'cookie' that d80211 returns from alloc_hw
   to be an opaque value to the driver. Turned out that it wasn't
   such a great idea but since it was generally a clean up I kept
   this patch to base my other patches on.

004-bcm43xx-adjust.patch:
   bcm43xx: adjust for the d80211 changes

   This adjusts bcm43xx for above changes with the cookie pointer.

005-d80211-reduce-mdev-1.patch
006-d80211-reduce-mdev-2.patch
   d80211: reduce mdev usage

   These two patches reduce mdev madness and change a lot of functions
   to take a struct ieee80211_local * instead of the master netdev

007-d80211-cleanup-rxmgmt.patch
   d80211: reduce mdev usage, fix ieee80211_rx_mgmt

   Cleans up the ieee80211_rx_mgmt and related code

008-d80211-scan-sanity.patch
   d80211: reduce master ieee80211_ptr deref in scan routines

   Similar to the reduce mdev patches, just for the scan routines

009-d80211-convert-spaces.patch
   d80211: convert leading spaces to tabs

   I hated working on the code, so I did this. The next patch
   breaks everything anyway.

010-d80211-proto.patch
   d80211: convert to an 802.11 protocol

   Converts d80211 to be a protocol together with tons of
   cleanups and more. Hard to describe in two lines.

011-bcm43xx-adjust-proto.patch
   bcm43xx: adjust to register a real struct net_device

   makes bcm43xx function after the previous patch

Have fun!

johannes


--=-/BB6FCSc05L2gPW4WHpW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARU4FtaVg1VMiehFYAQLwNQ//WLyc/wTqKTbYFVnUPqt72aIgfpUdByIL
6R/+IkDjApOjQQs8GJRJucHiYwc70XPRIAdO5vzaF6DX2PtXZdBBkQW81/0MlDDV
Xg9yzYkjLWu6TvARoXJErkr+CNLnL4JAHQdaHf8LFWwDQ0Vxg/3YTrwRPpM6EmJt
NISEVVIK2HL0hX8xQOgnz/DFbfRhS3KD93nrfsGaJzCqw6qj25slZsHuFICi2msm
NaMUGyJEuGRKAnFgFGj202LByngFnNdoG9PgMuRarTP3qCwfbGwVQ4Vrc+514OQj
Qr83DyMUOGuju86o0Smv1uI4bO/LUEsyDgK1rg24xXTIMAVAtfnUQ2Rq73XHsuMT
aUy0vqyHxJKcktO10750/fwDVje06EteVcW6RKk3FVpr3PfEWYE0URiJ/pl2F2dG
zLbQkOdPv4o7mF49v5slo7lUDXKpT/yeCBbVnqwH7/eds1sdRNuA50NCcIvH32jE
m7bEF1X6nVFk9EKCuN5+FonZ+WkR9K0li7M46hI/4USmkKAbBkKGOcUV9GQUkBGn
gqM6zR75zcXKVJ3TPN5nKyY3mXqd+BApUr+COWY8/w0/HJW7uK/cMjo/I3K47Q0J
PhVHk3PQiXGr7XGhwuU0PRgXMfH2m26ju9BwumuaMmpGVAs1LXP56/wbjkyJrng7
Aza/Jrx1k5M=
=upRF
-----END PGP SIGNATURE-----

--=-/BB6FCSc05L2gPW4WHpW--

