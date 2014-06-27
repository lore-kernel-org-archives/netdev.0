From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next v2 3/5] dp83640: Verify calibration pin assignment
Date: Fri, 27 Jun 2014 12:05:31 +0200
Message-ID: <1403863533-27675-4-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:52645 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753209AbaF0KGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:06:05 -0400
In-Reply-To: <1403863533-27675-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This constraints the pin assignment to not allow the calibration functi=
on to
be reassigned and only allow reassigning the calibratin pin if only one=
 phy is
connected.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index eabecff..ab48112 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -510,6 +510,16 @@ static int ptp_dp83640_enable(struct ptp_clock_inf=
o *ptp,
 static int ptp_dp83640_verify(struct ptp_clock_info *ptp, unsigned int=
 pin,
 			      enum ptp_pin_function func, unsigned int chan)
 {
+	struct dp83640_clock *clock =3D
+		container_of(ptp, struct dp83640_clock, caps);
+
+	if (clock->caps.pin_config[pin].func =3D=3D PTP_PF_PHYSYNC &&
+	    !list_empty(&clock->phylist))
+		return 1;
+
+	if (func =3D=3D PTP_PF_PHYSYNC)
+		return 1;
+
 	return 0;
 }
=20
--=20
1.9.3
