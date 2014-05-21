From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH 2/2] mISDN: use mod_timer()
Date: Wed, 21 May 2014 21:10:06 +0200
Message-ID: <1400699406-31294-2-git-send-email-manuel.schoelling@gmx.de>
References: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: manuel.schoelling@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400699406-31294-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code for resetting the timer can be simplified if mod_timer() is us=
ed
instead of del_timer() followed by add_timer().

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/isdn/mISDN/l1oip_core.c |    8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip=
_core.c
index 1c2bc36..a4c6cc0 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -288,9 +288,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, =
u8 channel, u32 chanmask,
=20
 	/* restart timer */
 	if (time_before(hc->keep_tl.expires - 5 * HZ, jiffies)) {
-		del_timer(&hc->keep_tl);
-		hc->keep_tl.expires =3D jiffies + L1OIP_KEEPALIVE * HZ;
-		add_timer(&hc->keep_tl);
+		mod_timer(&hc->keep_tl, jiffies + L1OIP_KEEPALIVE * HZ);
 	} else
 		hc->keep_tl.expires =3D jiffies + L1OIP_KEEPALIVE * HZ;
=20
@@ -624,9 +622,7 @@ multiframe:
 	if (time_before(hc->timeout_tl.expires - 5 * HZ, jiffies)
 	    || !hc->timeout_on) {
 		hc->timeout_on =3D 1;
-		del_timer(&hc->timeout_tl);
-		hc->timeout_tl.expires =3D jiffies + L1OIP_TIMEOUT * HZ;
-		add_timer(&hc->timeout_tl);
+		mod_timer(&hc->timeout_tl, jiffies + L1OIP_TIMEOUT * HZ);
 	} else /* only adjust timer */
 		hc->timeout_tl.expires =3D jiffies + L1OIP_TIMEOUT * HZ;
=20
--=20
1.7.10.4
