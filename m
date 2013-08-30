From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 6/9] net: airo: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:49 +0200
Message-ID: <1377878932-26881-7-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55480 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886Ab3H3QKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:10:14 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Acked-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/wireless/airo.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index d0adbaf..7fe1964 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2693,7 +2693,7 @@ static struct net_device *init_wifidev(struct air=
o_info *ai,
 	dev->base_addr =3D ethdev->base_addr;
 	dev->wireless_data =3D ethdev->wireless_data;
 	SET_NETDEV_DEV(dev, ethdev->dev.parent);
-	memcpy(dev->dev_addr, ethdev->dev_addr, dev->addr_len);
+	eth_hw_addr_inherit(dev, ethdev);
 	err =3D register_netdev(dev);
 	if (err<0) {
 		free_netdev(dev);
--=20
1.7.10.4
