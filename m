From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 net-next 3/5] dp83640: Prune rx timestamp list before reading from it
Date: Tue, 3 Nov 2015 09:34:06 +0100
Message-ID: <1446539648-8355-4-git-send-email-stefan.sorensen@spectralink.com>
References: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0141.outbound.protection.outlook.com ([157.56.110.141]:45091
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750788AbbKCIwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 03:52:33 -0500
In-Reply-To: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
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
index 69a2f56..39ac633 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1398,6 +1398,7 @@ static bool dp83640_rxtstamp(struct phy_device *p=
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
