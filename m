From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] d80211: Only free WEP crypto ciphers when they have been allocated correctly.
Date: Sat, 6 Jan 2007 12:29:11 -0500
Message-ID: <200701061229.16632.flamingice@sourmilk.net>
References: <459FD5C4.9070301@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1740116.h37kcHEfsb";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:52741 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbXAFR3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:29:50 -0500
To: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
In-Reply-To: <459FD5C4.9070301@kpnplanet.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1740116.h37kcHEfsb
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 06 January 2007 12:00, Gertjan van Wingerde wrote:
> The d80211 stack still tries to free the WEP crypto ciphers, even when
> allocating them previously has failed.=20
Actually, the code might not even have tried to allocate them. The ciphers =
are=20
guaranteed to be allocated when the device is registered however, so we=20
should be able to free it safely on unregister.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/ieee80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..926d160 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4715,6 +4715,7 @@ void ieee80211_unregister_hw(struct ieee
 	skb_queue_purge(&local->skb_queue_unreliable);
=20
 	ieee80211_dev_free_index(local);
+	ieee80211_wep_free(local);
 	ieee80211_led_exit(local);
 }
 EXPORT_SYMBOL(ieee80211_unregister_hw);
@@ -4724,7 +4725,6 @@ void ieee80211_free_hw(struct ieee80211_
 	struct ieee80211_local *local =3D hw_to_local(hw);
=20
 	ieee80211_if_free(local->mdev);
=2D	ieee80211_wep_free(local);
 	ieee80211_dev_free(local);
 }
 EXPORT_SYMBOL(ieee80211_free_hw);


--nextPart1740116.h37kcHEfsb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFn9xsT3Oqt9AH4aERAgrvAKDMllDTnM5n5dixZydhel5wfPuDoQCgjWfP
cuotNofo5hrlJ5zJcUC8OMs=
=67Vv
-----END PGP SIGNATURE-----

--nextPart1740116.h37kcHEfsb--
