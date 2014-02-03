From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] net:phy:dp83640: Do not hardcode timestamping event edge
Date: Mon,  3 Feb 2014 15:36:50 +0100
Message-ID: <1391438210-21941-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:60808 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752222AbaBCOzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 09:55:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the external timestamping code it hardcoded to use
the rising edge even though the hardware has configurable event
edge detection. This patch change the code to use falling edge
detection if PTP_FALLING_EDGE is set in the user supplied flags.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index baa1a75..80c5fc8 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -440,7 +440,10 @@ static int ptp_dp83640_enable(struct ptp_clock_inf=
o *ptp,
 		if (on) {
 			gpio_num =3D extts_gpio[index];
 			evnt |=3D (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
-			evnt |=3D EVNT_RISE;
+			if (rq->extts.flags & PTP_FALLING_EDGE)
+				evnt |=3D EVNT_FALL;
+			else
+				evnt |=3D EVNT_RISE;
 		}
 		ext_write(0, phydev, PAGE5, PTP_EVNT, evnt);
 		return 0;
--=20
1.8.5.3
