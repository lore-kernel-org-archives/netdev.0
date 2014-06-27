From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 4/5] dp83640: Get calibration pin with ptp_find_pin
Date: Fri, 27 Jun 2014 12:05:32 +0200
Message-ID: <1403863533-27675-5-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:52654 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753209AbaF0KGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:07 -0400
In-Reply-To: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46or consistency, use the ptp_find_pin function to get the calibration=
 pin,
not gpio_tab.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index ab48112..293ad06 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -609,7 +609,11 @@ static void recalibrate(struct dp83640_clock *cloc=
k)
 	u16 cal_gpio, cfg0, evnt, ptp_trig, trigger, val;
=20
 	trigger =3D CAL_TRIGGER;
-	cal_gpio =3D gpio_tab[CALIBRATE_GPIO];
+	cal_gpio =3D 1 + ptp_find_pin(clock->ptp_clock, PTP_PF_PHYSYNC, 0);
+	if (cal_gpio < 1) {
+		pr_err("PHY calibration pin not avaible - PHY is not calibrated.");
+		return;
+	}
=20
 	mutex_lock(&clock->extreg_lock);
=20
--=20
1.9.3
