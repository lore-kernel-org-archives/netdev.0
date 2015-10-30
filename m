From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 3/5] dp83640: Prune rx timestamp list before reading from it
Date: Fri, 30 Oct 2015 13:14:02 +0100
Message-ID: <1446207244-2206-4-git-send-email-stefan.sorensen@spectralink.com>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0140.outbound.protection.outlook.com ([157.56.110.140]:22221
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752372AbbJ3M3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 08:29:51 -0400
In-Reply-To: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The list of rx timestamps are currently only pruned of old entries when=
 a
new entry is inserted. If no new entries are added, old timestamps may
survive beyond their lifetime, possible causing them to be attached to
packets with the same sequence number after a rollover.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index f3e812b..c1f70b7 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1394,6 +1394,7 @@ static bool dp83640_rxtstamp(struct phy_device *p=
hydev,
 		return false;
=20
 	spin_lock_irqsave(&dp83640->rx_lock, flags);
+	prune_rx_ts(dp83640);
 	list_for_each_safe(this, next, &dp83640->rxts) {
 		rxts =3D list_entry(this, struct rxts, list);
 		if (match(skb, type, rxts)) {
--=20
2.5.0
