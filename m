From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-12-19
Date: Wed, 19 Dec 2012 13:32:20 -0500
Message-ID: <20121219183220.GB1912@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38365 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab2LSSf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 13:35:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull these fixes for the 3.8 stream.

Gabor Juhos provides and rt2x00 fix to properly clear-out the skb->cb
for reporting tx_status.  Recent changes made this necessary where it
previously was not.

Vladimir Kondratiev gives us a fix for a build issue that caused some
ath9k devices to be skipped in the build based on unrelated config
choices.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit c1e37ea287979052e3eab441e58da3899a8e2389:

  net: fec: forbid FEC_PTP on SoCs that do not support (2012-12-18 16:26:18=
 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to d67df2b9edfc42ccc0a9ee5332e2821d487d6b3b:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-12-19 13:00:00 -0500)

----------------------------------------------------------------

Gabor Juhos (1):
      rt2x00: zero-out rx_status

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Vladimir Kondratiev (1):
      wireless: fix Atheros drivers compilation

 drivers/net/wireless/Makefile           | 2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 062dfdf..67156ef 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -47,7 +47,7 @@ obj-$(CONFIG_RT2X00)	+=3D rt2x00/
=20
 obj-$(CONFIG_P54_COMMON)	+=3D p54/
=20
-obj-$(CONFIG_ATH_COMMON)	+=3D ath/
+obj-$(CONFIG_ATH_CARDS)		+=3D ath/
=20
 obj-$(CONFIG_MAC80211_HWSIM)	+=3D mac80211_hwsim.o
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index 4ffb6a5..44f8b3f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -685,6 +685,14 @@ void rt2x00lib_rxdone(struct queue_entry *entry, gfp_t=
 gfp)
 	 * to mac80211.
 	 */
 	rx_status =3D IEEE80211_SKB_RXCB(entry->skb);
+
+	/* Ensure that all fields of rx_status are initialized
+	 * properly. The skb->cb array was used for driver
+	 * specific informations, so rx_status might contain
+	 * garbage.
+	 */
+	memset(rx_status, 0, sizeof(*rx_status));
+
 	rx_status->mactime =3D rxdesc.timestamp;
 	rx_status->band =3D rt2x00dev->curr_band;
 	rx_status->freq =3D rt2x00dev->curr_freq;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ0gg0AAoJEJctW/TcYTgGexIP/0Qm5wLE7PuKV+NXfoPyySv6
sp4ZkXsboZ0HXjZBjD1pn4aBjzU4G67tRThmHvWlIwaYgWXY3aDwXpvsy+JRCzTh
xoFlp83u2wmIJSKoTiF9HEThPH65pQszAvn7AuzMIERnr1KexE0Iy9M5bIPOgGzm
H4aOIGfITeh3SZa3NtschWGSbSAnJZfka123IuYNVGG5CVaq2B6yyzh3Ut+CdnEh
xlaQ+ppoL0FyBykxou7B1proMzIvca1Ul2pp9sXgMPAqmNkAJi6Wnu46Q/hQKy3J
7dIJhY86oFGQnmpdh/X5NMqTV2iSyOnKj+ZvSzR7X1VavKcAXqEUHEld7tcpdILn
unAoIHDDSPq+Cfw7uD4Z1hpP7zYZRJ69MSr8ZcpulGe7b6jhbYD0deJeE5wz2Blg
1frW6KeoXNczCdEUySIpGvYGSZLWy/1Pnh1sW7pk2n3zUlyoRP8bjyOLbBTdPC3Q
1nfpSBiobQizQ8xvBC5YVv7FN0FHK67NsV5R1A+f8O+0hObYGg/f2SwMuT1oefqT
ZarLR+m7a9MEBSzPY8aYbj9sVOnSrnQqP/aLKv1qjl3zVtIe0YyyQQWTgA85iOIM
bL7ScFcsunOSrN47ZjKCxwMh8EuchcE8kj6FKfeMOO7qumfCVktK3ykVBohv1aCe
jy4YE+nmPlnGSxtpvnbq
=wDOd
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
