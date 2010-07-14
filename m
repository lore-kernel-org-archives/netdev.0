From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH] bonding: fix a buffer overflow in bonding_show_queue_id.
Date: Thu, 15 Jul 2010 00:24:37 +0200
Message-ID: <1279146277-9381-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
To: bonding-devel@lists.sourceforge.net, andy@greyhouse.net,
	fubar@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.151]:21610 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab0GNWYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jul 2010 18:24:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The test for buffer overflow ensures we have room for 6 more bytes.
sprintf, called with %s:%d, slave->dev->name, slave->queue_id may yield
far more than 6 bytes.

The correct test is res > (PAGE_SIZE - IFNAMSIZ - 6) .

Signed-off-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 drivers/net/bonding/bond_sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bon=
d_sysfs.c
index f9a0343..1a99764 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1427,8 +1427,8 @@ static ssize_t bonding_show_queue_id(struct devic=
e *d,
=20
 	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
-		if (res > (PAGE_SIZE - 6)) {
-			/* not enough space for another interface name */
+		if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
+			/* not enough space for another interface_name:queue_id pair */
 			if ((PAGE_SIZE - res) > 10)
 				res =3D PAGE_SIZE - 10;
 			res +=3D sprintf(buf + res, "++more++ ");
--=20
1.7.1



