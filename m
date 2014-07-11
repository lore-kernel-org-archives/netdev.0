From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Fri, 11 Jul 2014 08:18:26 +0200
Message-ID: <1405059506-3996-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:39335
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752566AbaGKGSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 02:18:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom the dp86340 Software Development Guide:
  Event timestamp values should be adjusted by 3*reference clock period=
 +
  11 ns =3D 35 ns to compensate for input path and synchronization dela=
ys.

So subtract 35ns from event timestamps.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 53bd1af..76fbd39 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -755,6 +755,9 @@ static int decode_evnt(struct dp83640_private *dp83=
640,
 	event.type =3D PTP_CLOCK_EXTTS;
 	event.timestamp =3D phy2txts(&dp83640->edata);
=20
+	/* Compensate for input path and synchronization delays */
+	event.timestamp -=3D 35;
+
 	for (i =3D 0; i < N_EXT_TS; i++) {
 		if (ext_status & exts_chan_to_edata(i)) {
 			event.index =3D i;
--=20
1.9.3
