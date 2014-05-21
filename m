From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH v2 1/2] mISDN: Use time_before()
Date: Wed, 21 May 2014 22:08:47 +0200
Message-ID: <1400702928-29110-1-git-send-email-manuel.schoelling@gmx.de>
References: <537CFE29.7050100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: manuel.schoelling@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537CFE29.7050100@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_before() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/isdn/mISDN/l1oip_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip=
_core.c
index 2c0d2c2..084f936 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -287,7 +287,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, =
u8 channel, u32 chanmask,
 	p =3D frame;
=20
 	/* restart timer */
-	if ((int)(hc->keep_tl.expires-jiffies) < 5 * HZ) {
+	if (time_before(hc->keep_tl.expires, jiffies + 5 * HZ)) {
 		del_timer(&hc->keep_tl);
 		hc->keep_tl.expires =3D jiffies + L1OIP_KEEPALIVE * HZ;
 		add_timer(&hc->keep_tl);
@@ -621,7 +621,7 @@ multiframe:
 		goto multiframe;
=20
 	/* restart timer */
-	if ((int)(hc->timeout_tl.expires-jiffies) < 5 * HZ || !hc->timeout_on=
) {
+	if (time_before(hc->timeout_tl.expires, jiffies + 5 * HZ) || !hc->tim=
eout_on) {
 		hc->timeout_on =3D 1;
 		del_timer(&hc->timeout_tl);
 		hc->timeout_tl.expires =3D jiffies + L1OIP_TIMEOUT * HZ;
--=20
1.7.10.4
