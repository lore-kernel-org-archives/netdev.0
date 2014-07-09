From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Wed, 9 Jul 2014 12:22:23 +0200
Message-ID: <1404901343-19445-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.190] ([207.46.163.190]:7437 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755193AbaGIKYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 06:24:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom the dp86340 Software Development Guide:
  Event timestamp values should be adjusted by 3*reference clock period=
 +
  11 ns =3D 35 ns to compensate for input path and synchronization dela=
ys.

So subtract 35ns from event timestamps.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
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
