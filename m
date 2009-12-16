From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 4/7] can/at91: don't check platform_get_irq's return value against zero
Date: Wed, 16 Dec 2009 17:10:06 +0100
Message-ID: <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de>
 <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934617AbZLPQKr@vger.kernel.org>
In-Reply-To: <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_get_irq returns -ENXIO on failure, so !irq was probably
always true.  Better use (int)irq <=3D 0.  Note that a return value of
zero is still handled as error even though this could mean irq0.

This is a followup to 305b3228f9ff4d59f49e6d34a7034d44ee8ce2f0 that
changed the return value of platform_get_irq from 0 to -ENXIO on error.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: David Vrabel <dvrabel@arcom.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>
Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>
Cc: netdev@vger.kernel.org
---
 drivers/net/can/at91_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index cbe3fce..631d404 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1037,7 +1037,7 @@ static int __init at91_can_probe(struct platform_=
device *pdev)
=20
 	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	irq =3D platform_get_irq(pdev, 0);
-	if (!res || !irq) {
+	if (!res || irq <=3D 0) {
 		err =3D -ENODEV;
 		goto exit_put;
 	}
--=20
1.6.5.2
