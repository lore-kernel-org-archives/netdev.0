From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] dp83640: Always decode received status frames
Date: Wed, 25 Jun 2014 14:40:16 +0200
Message-ID: <1403700016-11398-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164185.static.sonofon.dk ([213.83.164.185]:59235 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754195AbaFYMkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 08:40:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently status frames are only handled when packet timestamping is
enabled, but status frames are also needed for pin event timestamping.

=46ix by moving packet timestamping check to after status frame decode.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 6a999e6..9408157 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1323,15 +1323,15 @@ static bool dp83640_rxtstamp(struct phy_device =
*phydev,
 {
 	struct dp83640_private *dp83640 =3D phydev->priv;
=20
-	if (!dp83640->hwts_rx_en)
-		return false;
-
 	if (is_status_frame(skb, type)) {
 		decode_status_frame(dp83640, skb);
 		kfree_skb(skb);
 		return true;
 	}
=20
+	if (!dp83640->hwts_rx_en)
+		return false;
+
 	SKB_PTP_TYPE(skb) =3D type;
 	skb_queue_tail(&dp83640->rx_queue, skb);
 	schedule_work(&dp83640->ts_work);
--=20
1.9.3
