From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] net:phy:dp83640: Declare that TX timestamping possible
Date: Mon,  3 Feb 2014 15:36:35 +0100
Message-ID: <1391438195-21888-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:60808 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751294AbaBCOzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 09:55:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the SKBTX_IN_PROGRESS bit in tx_flags dp83640_txtstamp when doing
tx timestamps as per Documentation/networking/timestamping.txt.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index dfb132e..ae95a9a 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1273,6 +1273,7 @@ static void dp83640_txtstamp(struct phy_device *p=
hydev,
 		}
 		/* fall through */
 	case HWTSTAMP_TX_ON:
+		skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS;
 		skb_queue_tail(&dp83640->tx_queue, skb);
 		schedule_work(&dp83640->ts_work);
 		break;
--=20
1.8.5.3
