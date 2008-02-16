From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: [PATCH][2.6.25-rc2] Fix double lock in do_setlink introduced by 45b503548210fe6f23e92b856421c2a3f05fd034
Date: Sun, 17 Feb 2008 02:57:25 +0300
Message-ID: <200802170257.26406.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1672911.79msO7FFKx";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754838AbYBPX6c@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1672911.79msO7FFKx
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

[   58.097923] =============================================
[   58.098883] [ INFO: possible recursive locking detected ]
[   58.099603] 2.6.25-rc2-1avb #1
[   58.100013] ---------------------------------------------
[   58.100672] wpa_supplicant/2682 is trying to acquire lock:
[   58.100672]  (dev_base_lock){-.--}, at: [<c0278697>] do_setlink+0x327/0x3
[   58.100672]
[   58.100672] but task is already holding lock:
[   58.100672]  (dev_base_lock){-.--}, at: [<c0278680>] do_setlink+0x310/0x3

with final effect

[   58.537509] Kernel panic - not syncing: Aiee, killing interrupt handler!

Signed-off-by: Andrey Borzenkov <arvidjaar@mail.ru>

---

 net/core/rtnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ecb02af..dd9e4da 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -853,7 +853,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		if (dev->link_mode != nla_get_u8(tb[IFLA_LINKMODE])) {
 			write_lock_bh(&dev_base_lock);
 			dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
-			write_lock_bh(&dev_base_lock);
+			write_unlock_bh(&dev_base_lock);
 			modified = 1;
 		}
 	}

--nextPart1672911.79msO7FFKx
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)

iEYEABECAAYFAke3eGYACgkQR6LMutpd94xnDACgqPoLl9TgypB1pWoItETNPbw4
2+8AnRtL15Dne3hkBHz7J3ap9po+IfYb
=BHQL
-----END PGP SIGNATURE-----

--nextPart1672911.79msO7FFKx--
